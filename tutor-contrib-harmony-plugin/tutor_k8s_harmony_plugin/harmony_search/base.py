import json
import typing

from tutor import utils


class BaseSearchAPI:
    """
    Helper class to interact with the HarmonySearch
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
            "harmony-search-cluster-master-0",
            "--",
            "bash",
            "-c",
        ]
        # Must be specified by subclasses
        self._curl_base = None

    def run_command(self, curl_options) -> typing.Union[dict, bytes]:
        """
        Invokes a curl command on the first HarmonySearch pod.

        If possible returns the parsed json from the HarmonySearch response.
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
        Runs a GET request on the HarmonySearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the HarmonySearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_command(["-XGET", f"https://localhost:9200/{endpoint}"])

    def post(self, endpoint: str, data: dict) -> typing.Union[dict, bytes]:
        """
        Runs a POST request on the HarmonySearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the HarmonySearch response.
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

    def put(self, endpoint: str, data: dict) -> typing.Union[dict, bytes]:
        """
        Runs a PUT request on the HarmonySearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the HarmonySearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_command(
            [
                "-XPUT",
                f"https://localhost:9200/{endpoint}",
                "-d",
                f"'{json.dumps(data)}'",
                "-H",
                '"Content-Type: application/json"',
            ]
        )
