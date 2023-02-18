from glob import glob
import os
import pkg_resources

from tutor import hooks

from .__about__ import __version__

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
        "INGRESS_HOST_LIST": [ ]
    },
    "overrides": {
        # Don't use Caddy as a per-instance external web proxy, but do still use it
        # for per-instance load balancing.
        "ENABLE_WEB_PROXY": False,
        # We are using HTTPS
        "ENABLE_HTTPS": True,
    },
}

hooks.Filters.CONFIG_DEFAULTS.add_items(
    [
        (f"MULTI_K8S_{key}", value)
        for key, value in config.get("defaults", {}).items()
    ]
)

hooks.Filters.CONFIG_OVERRIDES.add_items(list(config.get("overrides", {}).items()))

# Load all patches from the "patches" folder
for path in glob(
    os.path.join(
        pkg_resources.resource_filename("tutor_multi_k8s_plugin", "patches"),
        "*",
    )
):
    with open(path, encoding="utf-8") as patch_file:
        hooks.Filters.ENV_PATCHES.add_item((os.path.basename(path), patch_file.read()))
