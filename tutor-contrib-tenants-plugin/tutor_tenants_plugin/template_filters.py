import copy
from copy import deepcopy
from typing import Optional

from tutormfe.plugin import iter_mfes

from .hook_utils import merge_dict


def get_site_configuration(additional_domain: dict) -> dict:
    """
    Check the additional_domain for a `site_configuration`
    key and return it. Otherwise return a default Site Configuration
    for the LMS based on the domain.
    """

    domain = additional_domain["domain"]
    site_configuration = additional_domain.get("site_configuration")

    if site_configuration is not None:
        return site_configuration

    return {
        "SITE_NAME": domain,
        "SESSION_COOKIE_DOMAIN": domain,
        "LMS_BASE": domain,
        "LMS_ROOT": f"https://{domain}",
        "version": 0,
    }


def get_base_tenant_configuration(site_config: dict, lms_host: str, mfe_host: str, enable_https: bool) -> dict:
    """
    Get base tenant configuration for main URL if eox tenant is enabled.
    It makes sure third_party_auth works as expected if enabled.
    To enable third_party_auth set `FEATURES["ENABLE_THIRD_PARTY_AUTH"] = True`
    in common features or tenant settings.
    """
    protocol = "https" if enable_https else "http"
    default = {
        "version": 0,
        "EDNX_TENANT_INSTALLED_APPS": ["common.djangoapps.third_party_auth"],
        "LMS_BASE": lms_host,
        "LMS_ROOT_URL": f"{protocol}://{lms_host}",
        "PREVIEW_LMS_BASE": f"preview.{lms_host}",
        "FEATURES": {"PREVIEW_LMS_BASE": f"preview.{lms_host}"},
        "EDNX_USE_SIGNAL": True,
        "COURSE_AUTHORING_MICROFRONTEND_URL": f"{protocol}://{mfe_host}/authoring",
    }
    return {"lms_configs": merge_dict(default, site_config)}


def _get_default_common_config(protocol: str, domain: str):
    return {
        "CMS_BASE": f"studio.{domain}",
        "EDNX_USE_SIGNAL": True,
        "FEATURES": {"PREVIEW_LMS_BASE": f"preview.{domain}"},
        "HOSTNAME_MODULESTORE_DEFAULT_MAPPINGS": {f"preview.{domain}": "draft-preferred"},
        "IDA_LOGOUT_URI_LIST": [f"{protocol}://studio.{domain}/logout/"],
        "LMS_BASE": domain,
        "LMS_ROOT_URL": f"{protocol}://{domain}",
        "LOGIN_REDIRECT_WHITELIST": [f"studio.{domain}"],
        "PREVIEW_LMS_BASE": f"preview.{domain}",
        "SESSION_COOKIE_DOMAIN": domain,
        "SHARED_COOKIE_DOMAIN": domain,
        "SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT": f"{protocol}://{domain}",
    }


def _get_mfe_theme_urls(mfe_theme: Optional[str], mfe_theme_cdn: str, paragon_theme_urls: dict) -> dict:
    if mfe_theme and mfe_theme_cdn:
        mfe_theme_cdn = mfe_theme_cdn.removesuffix('/')
        paragon_theme_urls = deepcopy(paragon_theme_urls)
        paragon_theme_urls["core"]["urls"]["brandOverride"] = f"{mfe_theme_cdn}/core.min.css"
        paragon_theme_urls["variants"]["light"]["urls"]["brandOverride"] = f"{mfe_theme_cdn}/{mfe_theme}.min.css"
        return {
            "PARAGON_THEME_URLS": paragon_theme_urls,
        }
    else:
        return {}


def _get_mfe_common_config(
    protocol: str,
    domain: str,
    mfe_domain: str,
    mfe_theme: Optional[str],
    mfe_theme_cdn: str,
    paragon_theme_urls: dict,
):
    mfe_base = f"{protocol}://{mfe_domain}"
    lms_base = f"{protocol}://{domain}"
    return {
        "BASE_URL": mfe_domain,
        "LMS_BASE_URL": lms_base,
        "STUDIO_BASE_URL": f"{protocol}://studio.{domain}",
        "LEARNING_BASE_URL": f"{mfe_base}/learning",
        "LOGIN_URL": f"{lms_base}/login",
        "LOGOUT_URL": f"{lms_base}/logout",
        "MARKETING_SITE_BASE_URL": lms_base,
        "REFRESH_ACCESS_TOKEN_ENDPOINT": f"{lms_base}/login_refresh",
        "FAVICON_URL": f"{lms_base}/favicon.ico",
        "LOGO_URL": f"{lms_base}/theming/asset/images/logo.png",
        "LOGO_WHITE_URL": f"{lms_base}/theming/asset/images/logo.png",
        "LOGO_TRADEMARK_URL": f"{lms_base}/theming/asset/images/logo.png",
        **_get_mfe_theme_urls(mfe_theme, mfe_theme_cdn, paragon_theme_urls),
    }


def get_tenant_configuration(
    additional_domain: dict,
    enable_https: bool,
    mfe_theme_cdn: str,
    paragon_theme_urls,
) -> dict:
    """
    Check the additional_domain for a `site_configuration`
    key and return it. Otherwise return a default Tenant Configuration
    for the LMS based on the domain.
    """

    site_configuration = additional_domain.get("site_configuration", {})
    domain = additional_domain["domain"]
    mfe_domain = additional_domain.get("mfe_domain", None)
    mfe_theme = additional_domain.get("mfe_theme", None)
    proxy = additional_domain.get("proxy")
    protocol = "https" if enable_https else "http"
    final_config = {}
    if proxy == "lms:8000":
        default_common_config = _get_default_common_config(protocol, domain)
        if mfe_domain:
            mfe_base = f"{protocol}://{mfe_domain}"
            default_common_config["MFE_CONFIG"] = _get_mfe_common_config(
                protocol, domain, mfe_domain, mfe_theme, mfe_theme_cdn, paragon_theme_urls
            )
            default_common_config["LEARNING_MICROFRONTEND_URL"] = f"{mfe_base}/learning"
            for app_name, app in iter_mfes():
                if app_name == "authn":
                    default_common_config.update(
                        {
                            "AUTHN_MICROFRONTEND_URL": f"{mfe_base}/authn",
                            "AUTHN_MICROFRONTEND_DOMAIN": f"{mfe_domain}/authn",
                        }
                    )
                if app_name == "account":
                    default_common_config["ACCOUNT_MICROFRONTEND_URL"] = f"{mfe_base}/account"
                    default_common_config["MFE_CONFIG"]["ACCOUNT_SETTINGS_URL"] = f"{mfe_base}/account"
                if app_name == "authoring":
                    default_common_config["COURSE_AUTHORING_MICROFRONTEND_URL"] = f"{mfe_base}/authoring"
                if app_name == "discussions":
                    default_common_config["DISCUSSIONS_MICROFRONTEND_URL"] = f"{mfe_base}/discussions"
                    default_common_config["MFE_CONFIG"]["DISCUSSIONS_MFE_BASE_URL"] = f"{mfe_base}/discussions"
                if app_name == "gradebook":
                    default_common_config["WRITABLE_GRADEBOOK_URL"] = f"{mfe_base}/gradebook"
                if app_name == "ora-grading":
                    default_common_config["ORA_GRADING_MICROFRONTEND_URL"] = f"{mfe_base}/ora-grading"
                if app_name == "profile":
                    default_common_config["PROFILE_MICROFRONTEND_URL"] = f"{mfe_base}/profile"
                    default_common_config["MFE_CONFIG"]["ACCOUNT_PROFILE_URL"] = f"{mfe_base}/profile"
                if app_name == "communications":
                    default_common_config["COMMUNICATIONS_MICROFRONTEND_URL"] = f"{mfe_base}/communications"
                    default_common_config["MFE_CONFIG"]["SCHEDULE_EMAIL_SECTION"] = True

            default_common_config["LOGIN_REDIRECT_WHITELIST"] += [f"{mfe_base}"]
            default_common_config["SITE_NAME"] = domain

        default_lms_config = {"EDNX_TENANT_INSTALLED_APPS": ["common.djangoapps.third_party_auth"]}
        default_config = merge_dict(copy.deepcopy(default_common_config), default_lms_config)
        lms_configuration = merge_dict(default_config, site_configuration)
        final_config = {
            "lms_configs": lms_configuration,
            "studio_configs": default_common_config,
        }
    elif proxy == "cms:8000":
        final_config = {"studio_configs": site_configuration}
    return final_config
