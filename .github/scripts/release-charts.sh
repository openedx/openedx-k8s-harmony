#!/usr/bin/env bash
# Publish new Helm chart versions as GitHub Releases, then update gh-pages index.yaml.
#
# Required tools: yq, helm, gh, cr
#
# Required environment:
#   GITHUB_REPOSITORY  owner/repo (set automatically on GitHub Actions)
#   GITHUB_SHA         commit to tag (set automatically on GitHub Actions)
#   GH_TOKEN or GITHUB_TOKEN or CR_TOKEN
#     GitHub token with permission to create releases and push to gh-pages
#
# Optional environment:
#   CHARTS_DIR     Charts directory (default: charts)
#   PACKAGE_DIR    helm package output directory (default: .cr-release-packages)
#   INDEX_DIR      chart-releaser index working directory (default: .cr-index)
#
# Example:
#   GITHUB_REPOSITORY=openedx/openedx-k8s-harmony \
#   GITHUB_SHA="$GITHUB_SHA" \
#   GH_TOKEN="$GITHUB_TOKEN" \
#   CR_TOKEN="$GITHUB_TOKEN" \
#   .github/scripts/release-charts.sh

set -euo pipefail

CHARTS_DIR=${CHARTS_DIR:-charts}
PACKAGE_DIR=${PACKAGE_DIR:-.cr-release-packages}
INDEX_DIR=${INDEX_DIR:-.cr-index}

package_new_charts() {
	mkdir -p "$PACKAGE_DIR"

	for chart_yaml in "$CHARTS_DIR"/*/Chart.yaml; do
		if [ ! -f "$chart_yaml" ]; then
			continue
		fi

		chart_dir=$(dirname "$chart_yaml")
		name=$(yq -r '.name' "$chart_yaml")
		version=$(yq -r '.version' "$chart_yaml")
		description=$(yq -r '.description' "$chart_yaml")
		tag="${name}-${version}"

		if [ -z "$name" ] || [ -z "$version" ]; then
			echo "Could not read name/version from $chart_yaml" >&2
			exit 1
		fi

		if git rev-parse --verify --quiet "refs/tags/$tag" >/dev/null; then
			echo "Skipping $chart_dir; tag $tag already exists"
			continue
		fi

		echo "Packaging $chart_dir as $tag"
		helm dependency build "$chart_dir"
		helm package "$chart_dir" --destination "$PACKAGE_DIR"

		package_file="${PACKAGE_DIR}/${name}-${version}.tgz"
		if [ ! -f "$package_file" ]; then
			echo "Expected package $package_file was not created" >&2
			exit 1
		fi

		echo "Creating draft release $tag"
		gh release create "$tag" \
			--draft \
			--title "$tag" \
			--notes "${description:-$name Helm chart $version}" \
			--target "$GITHUB_SHA" \
			"$package_file"

		echo "Publishing release $tag"
		gh release edit "$tag" --draft=false
		published=$((published + 1))
	done
}

update_helm_index() {
	owner=${GITHUB_REPOSITORY%/*}
	repo=${GITHUB_REPOSITORY#*/}

	mkdir -p "$INDEX_DIR"

	echo "Updating Helm repo index on gh-pages"
	cr index \
		--owner "$owner" \
		--git-repo "$repo" \
		--package-path "$PACKAGE_DIR" \
		--index-path "${INDEX_DIR}/index.yaml" \
		--token "$CR_TOKEN" \
		--push
}

published=0
git fetch --tags --force origin
package_new_charts

if [ "$published" -eq 0 ]; then
	echo "No new chart versions to publish"
	exit 0
fi

update_helm_index
echo "Published $published chart version(s)"
