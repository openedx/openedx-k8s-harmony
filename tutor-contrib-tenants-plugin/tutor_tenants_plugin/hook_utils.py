import functools
import itertools
from importlib import resources

from tutor import config as tutor_config
from tutor import env, hooks


def _template_escape(text):
    return text.replace("{", "{% raw %}{{% endraw %}")


_LARGE_TASK_CUT_MARKER = "\n#harmony-multi-tenant-large-task-break\n"

_TASK_SIZE_LIMIT = 100 * (2 ** 10)


def _split_script(script):
    segment = ""
    for src in map(_template_escape, script.split(_LARGE_TASK_CUT_MARKER)):
        if len(segment) + 1 + len(src) < _TASK_SIZE_LIMIT:
            segment += "\n" + src
        else:
            yield segment
            segment = src
    yield segment


def _large_cli_task(service, template, values):
    # Load config as `tutor.commands.jobs:do_callback()` does.
    import click

    context = click.get_current_context().obj
    config = tutor_config.load(context.root)

    script = env.render_str(config, template).strip()
    scripts = _split_script(script)
    scripts = zip(itertools.repeat(service), scripts)
    return values + list(scripts)


def bootstrap_plugin(config: dict):
    """
    Runs common initialisation tasks needed for any tutor plugin.
    """
    plugin_root = resources.files("tutor_tenants_plugin")
    tasks_dir = plugin_root / "templates" / "tenants" / "tasks"
    hooks.Filters.ENV_TEMPLATE_ROOTS.add_item(str(plugin_root / "templates"))
    hooks.Filters.ENV_TEMPLATE_TARGETS.add_items(
        [
            ("tenants/build", "plugins"),
            ("tenants/apps", "plugins"),
            ("tenants/k8s", "plugins"),
        ],
    )

    for patch_file in (plugin_root / "patches").glob("*"):
        hooks.Filters.ENV_PATCHES.add_item((
            patch_file.name,
            patch_file.read_text(encoding='utf-8')
        ), priority=100)

    hooks.Filters.CONFIG_DEFAULTS.add_items(
        [
            (f"HARMONY_MULTITENANT_{key}", value)
            for key, value in config["defaults"].items()
        ]
    )

    if "global_defaults" in config:
        hooks.Filters.CONFIG_DEFAULTS.add_items(list(config["global_defaults"].items()))

    if "overrides" in config:
        hooks.Filters.CONFIG_OVERRIDES.add_items(list(config["overrides"].items()))

    for task_file in sorted(tasks_dir.glob("*/*")):
        service, task = task_file.parts[-2:]
        template = task_file.read_text(encoding='utf-8')
        if task.endswith(".large"):
            # The output of some templates may become too large to be
            # passed to sh, so we render them ourselves and break up the
            # result in multiple scripts.
            #
            # See also `docs/large-tasks.rst`.
            callback = functools.partial(_large_cli_task, service, template)
            hooks.Filters.CLI_DO_INIT_TASKS.add()(callback)
        else:
            hooks.Filters.CLI_DO_INIT_TASKS.add_item((service, template))


def merge_dict(base_dict, override):
    """
    Merge two nested dicts.
    """
    if isinstance(base_dict, dict) and isinstance(override, dict):
        for key, value in override.items():
            base_dict[key] = merge_dict(base_dict.get(key, {}), value)
        return base_dict

    return override
