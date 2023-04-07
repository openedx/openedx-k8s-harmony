import json
import typing

from tutor import utils


class ElasticSearchAPI:
    """
    Helper class to interact with the ElasticSearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        self._command_base = [
            "kubectl",
            "exec",
            "--stdin",
            "--tty",
            "--namespace",
            namespace,
            "elasticsearch-master-0",
            "--",
            "bash",
            "-c",
        ]
        self._curl_base = ["curl", "--insecure", "-u", "elastic:${ELASTIC_PASSWORD}"]

    def run_command(self, curl_options) -> typing.Union[dict, bytes]:
        """
        Invokes a curl command on the first Elasticsearch pod.

        If possible returns the parsed json from the Elasticsearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        response = utils.check_output(
            *self._command_base, " ".join(self._curl_base + curl_options)
        )
        try:
            return json.loads(response)
        except (TypeError, ValueError):
            return response

    def get(self, endpoint):
        """
        Runs a GET request on the Elasticsearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the Elasticsearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_command(["-XGET", f"https://localhost:9200/{endpoint}"])

    def post(self, endpoint: str, data: dict) -> typing.Union[dict, bytes]:
        """
        Runs a POST request on the Elasticsearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the Elasticsearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_command(
            [
                "-XPOST",
                f"https://localhost:9200/{endpoint}",
                "-d",
                f"'{json.dumps(data)}'",
                "-H",
                '"Content-Type: application/json"',
            ]
        )
