import os

from importlib import resources
from tutor import hooks as tutor_hooks

try:
    from tutorforum.hooks import FORUM_ENV
except ImportError:
    FORUM_ENV = None

from . import commands
from .__about__ import __version__

PLUGIN_DIR_NAME = "tutor_k8s_harmony_plugin"


def is_plugin_loaded(plugin_name: str) -> bool:
    """
    Check if the provided plugin is loaded.
    """

    return plugin_name in tutor_hooks.Filters.PLUGINS_LOADED.iterate()


config = {
    "defaults": {
        "VERSION": __version__,
        # This plugin assumes you are using ingress-nginx as an ingress controller to provide
        # you with a central load balancer. The standard Ingress object uses annotations to
        # trigger the generation of certificates using cert-manager.
        # See: https://cert-manager.io/docs/usage/ingress/#supported-annotations
        "INGRESS_CLASS_NAME": "nginx",
        # Currently there is no easy way to autodiscover a list of public hosts of your
        # Open edX installation to add to your ingress routes. This especially evident
        # when installing additional plugins such as tutor-ecommerce or tutor-minio.
        # The workaround is to manually add a list of hosts to be routed to the caddy
        # instance.
        "ADDITIONAL_INGRESS_HOST_LIST": [],
        "ENABLE_SHARED_SEARCH_CLUSTER": False,
        "DEPLOYMENT_REVISION_HISTORY_LIMIT": 10,
    },
    "overrides": {
        # Don't use Caddy as a per-instance external web proxy, but do still use it
        # for per-instance load balancing.
        "ENABLE_WEB_PROXY": False,
        # We are using HTTPS
        "ENABLE_HTTPS": True,
        # We are using HTTPS
        "ELASTICSEARCH_SCHEME": "https",
        # Override the elasticsearch host to point to the internal cluster
        "ELASTICSEARCH_HOST": "harmony-search-cluster.{{ K8S_HARMONY_NAMESPACE }}.svc.cluster.local",
        # Disable the per-namespace elasticsearch instance
        "RUN_ELASTICSEARCH": False,
        # The list of indexes is defined in:
        # https://github.com/openedx/course-discovery/blob/master/course_discovery/settings/base.py
        # We need to keep a copy of this list so that we can prefix the index names when using shared ES.
        "DISCOVERY_INDEX_OVERRIDES": {
            "course_discovery.apps.course_metadata.search_indexes.documents.course": "{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX }}course",
            "course_discovery.apps.course_metadata.search_indexes.documents.course_run": "{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX }}course_run",
            "course_discovery.apps.course_metadata.search_indexes.documents.learner_pathway": "{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX }}learner_pathway",
            "course_discovery.apps.course_metadata.search_indexes.documents.person": "{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX }}person",
            "course_discovery.apps.course_metadata.search_indexes.documents.program": "{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX }}program",
        },
    },
    "unique": {
        "K8S_HARMONY_SEARCH_CLUSTER_HTTP_AUTH": "{{ K8S_NAMESPACE }}:{{ 24|random_string }}",
        "K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX": "{{ K8S_NAMESPACE }}-{{ 4|random_string|lower }}-",
    },
}

# Load all configuration entries
tutor_hooks.Filters.CONFIG_DEFAULTS.add_items(
    [(f"K8S_HARMONY_{key}", value) for key, value in config["defaults"].items()]
)

tutor_hooks.Filters.CONFIG_OVERRIDES.add_items(list(config["overrides"].items()))
tutor_hooks.Filters.CONFIG_UNIQUE.add_items(list(config["unique"].items()))

tutor_hooks.Filters.CLI_COMMANDS.add_item(commands.harmony)

tutor_hooks.Filters.ENV_TEMPLATE_ROOTS.add_item(
    str(resources.files(PLUGIN_DIR_NAME) / "templates")
)

tutor_hooks.Filters.ENV_TEMPLATE_TARGETS.add_items(
    [
        ("k8s_harmony/k8s", "plugins"),
    ]
)

tutor_hooks.Filters.ENV_TEMPLATE_VARIABLES.add_item(
    ("is_plugin_loaded", is_plugin_loaded)
)

# The patches from this plugin should be loaded after all other plugins so that
# the overrides configured for individual instances are themselves not overriden
# by the default patches of other plugins. The priority of these patches are
# therefore set to 100.
patches = resources.files(PLUGIN_DIR_NAME) / "patches"
for path in patches.glob("*"):
    with open(path, encoding="utf-8") as patch_file:
        tutor_hooks.Filters.ENV_PATCHES.add_item(
            (os.path.basename(path), patch_file.read()), priority=100
        )

if FORUM_ENV:

    @FORUM_ENV.add()
    def _add_forum_env_vars(env_vars: dict):
        """
        Override forum env vars to configure the search cluster.

        The default Elasticsearch configuraiton does not allow HTTP auth or CA
        cert path configuration. This needs to be done through overriding the
        default env values.
        """
        return {
            **env_vars,
            "SEARCH_SERVER": "{{ ELASTICSEARCH_SCHEME }}://{{ K8S_HARMONY_SEARCH_CLUSTER_HTTP_AUTH and (K8S_HARMONY_SEARCH_CLUSTER_HTTP_AUTH + '@') }}{{ ELASTICSEARCH_HOST }}:{{ ELASTICSEARCH_PORT }}",
            "ELASTICSEARCH_INDEX_PREFIX": '{{ K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX|default("") }}',
        }
