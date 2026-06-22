from tutor import hooks

from .__about__ import __version__
from .hook_utils import bootstrap_plugin
from .template_filters import get_base_tenant_configuration, get_site_configuration, get_tenant_configuration

# Configuration
config = {
    # Add here your new settings
    "defaults": {
        "VERSION": __version__,

        # Additional domains that you would like to add
        # A list of dictionaries with keys `proxy` and `domain`
        # [{"domain": "example.com", "proxy": "lms:8000" }]
        "ADDITIONAL_DOMAINS": [],
        # Configure redirect rules through Caddy
        "REDIRECTS": [],
        # eox-tenant for multi domain support
        "USE_EOX_TENANT": False,
        # The common CDN origin for MFE themes when using runtime theming
        "MFE_THEME_CDN_ORIGIN": "",
        "PARAGON_THEME_URLS": {
            "core": {
                "urls": {
                    "default": "https://cdn.jsdelivr.net/npm/@openedx/paragon@$paragonVersion/dist/core.min.css",
                }
            },
            "defaults": {
                "light": "light",
            },
            "variants": {
                "light": {
                    "urls": {
                        "default": "https://cdn.jsdelivr.net/npm/@openedx/paragon@$paragonVersion/dist/light.min.css",
                    }
                },
            },
        }
    },
    # Add here settings that don't have a reasonable default for all users. For
    # instance: passwords, secret keys, etc.
    "unique": {},
}

hooks.Filters.ENV_TEMPLATE_FILTERS.add_items([
    ("get_site_configuration", get_site_configuration),
    ("get_base_tenant_configuration", get_base_tenant_configuration),
    ("get_tenant_configuration", get_tenant_configuration)
])

bootstrap_plugin(config)
