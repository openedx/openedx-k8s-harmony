from glob import glob
import os
import pkg_resources

from tutor import hooks

from .__about__ import __version__

hooks.Filters.CONFIG_DEFAULTS.add_item(("MULTI_K8S_VERSION", __version__))
# This plugin assumes you are using a central Traefik load balancer on your
# cluster but if you want, you could use something else like
# nginx + cert_manager, though that takes more effort to set up. In any case,
# this plugin sets up standard k8s Ingress objects on the k8s cluster, so you
# just need to have some working Ingress controller that can detect them and
# route traffic to them with automatic HTTPS cert provisioning.
# Use this MULTI_K8S_INGRESS_CLASS_NAME setting to specify the
# 'ingressClassName' so that your preferred load balancer will see each
# Open edX instance.
hooks.Filters.CONFIG_DEFAULTS.add_item(("MULTI_K8S_INGRESS_CLASS_NAME", "tutor-multi-traefik"))
hooks.Filters.CONFIG_OVERRIDES.add_items([
    # Don't use Caddy as a per-instance external web proxy, but do still use it
    # for per-instance load balancing. Eventually it would be nice to get rid of
    # it completely as it's not needed in this setup, but that would break
    # compatibility with existing Tutor k8s plugins that configure Caddy via
    # patches.
    ("ENABLE_WEB_PROXY", False),
    # We are using HTTPS
    ("ENABLE_HTTPS", True),
])

# Load all patches from the "patches" folder
for path in glob(
    os.path.join(
        pkg_resources.resource_filename("tutor_multi_k8s_plugin", "patches"),
        "*",
    )
):
    with open(path, encoding="utf-8") as patch_file:
        hooks.Filters.ENV_PATCHES.add_item((os.path.basename(path), patch_file.read()))
