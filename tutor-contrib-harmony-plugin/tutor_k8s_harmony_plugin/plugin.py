import os
from glob import glob

import pkg_resources
from tutor import hooks as tutor_hooks

from . import commands
from .__about__ import __version__

config = {
    "defaults": {
        "VERSION": __version__,
        "ELASTIC_HOST": "harmony-search-cluster.{{ K8S_HARMONY_NAMESPACE }}.svc.cluster.local",
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
        "INGRESS_HOST_LIST": [],
        "ENABLE_SHARED_HARMONY_SEARCH": False,
    },
    "overrides": {
        # Don't use Caddy as a per-instance external web proxy, but do still use it
        # for per-instance load balancing.
        "ENABLE_WEB_PROXY": False,
        # We are using HTTPS
        "ENABLE_HTTPS": True,
    },
    "unique": {
        "HARMONY_SEARCH_HTTP_AUTH": "{{ K8S_NAMESPACE }}:{{ 24|random_string }}",
        "HARMONY_SEARCH_INDEX_PREFIX": "{{ K8S_NAMESPACE }}-{{ 4|random_string|lower }}-",
    },
}

# Load all configuration entries
tutor_hooks.Filters.CONFIG_DEFAULTS.add_items(
    [(f"K8S_HARMONY_{key}", value) for key, value in config["defaults"].items()]
)

tutor_hooks.Filters.CONFIG_OVERRIDES.add_items(list(config["overrides"].items()))
tutor_hooks.Filters.CONFIG_UNIQUE.add_items(list(config["unique"].items()))

# Load all patches from the "patches" folder
for path in glob(
    os.path.join(
        pkg_resources.resource_filename("tutor_k8s_harmony_plugin", "patches"),
        "*",
    )
):
    with open(path, encoding="utf-8") as patch_file:
        tutor_hooks.Filters.ENV_PATCHES.add_item((os.path.basename(path), patch_file.read()))

tutor_hooks.Filters.CLI_COMMANDS.add_item(commands.harmony)
