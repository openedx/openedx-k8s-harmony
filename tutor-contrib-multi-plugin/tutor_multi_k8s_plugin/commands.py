import os

import click
from tutor import config as tutor_config
from tutor import env as tutor_env
from tutor.commands.k8s import K8sContext, kubectl_exec
from .elasticsearch import ElasticSearchAPI

@click.group(help="Commands and subcommands of the openedx-k8s-harmony.")
@click.pass_context
def harmony(context: click.Context) -> None:
    context.obj = K8sContext(context.obj.root)


@click.command(help="Create or update Elasticsearch users")
@click.pass_obj
def create_elasticsearch_user(context: click.Context):
    """
    Creates or updates the Elasticsearch user
    """
    config = tutor_config.load(context.root)
    namespace = config["K8S_HARMONY_NAMESPACE"]
    api = ElasticSearchAPI(namespace)
    username, password = config["ELASTICSEARCH_HTTP_AUTH"].split(":", 1)
    role_name = f"{username}_role"

    prefix = config["ELASTICSEARCH_INDEX_PREFIX"]
    api.post(
        f"_security/role/{role_name}",
        {"indices": [{"names": [f"{prefix}*"], "privileges": ["all"]}]},
    )

    api.post(
        f"_security/user/{username}",
        {
            "password": password,
            "enabled": True,
            "roles": [role_name],
            "full_name": username,
        },
    )


harmony.add_command(create_elasticsearch_user)
