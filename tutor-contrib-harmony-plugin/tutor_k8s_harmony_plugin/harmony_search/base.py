import json
import typing
import base64

from tutor import utils


class BaseSearchAPI:
    """
    Helper class to interact with the HarmonySearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        self._command_base = ["kubectl", "--namespace", namespace]
        self._exec_command = [*self._command_base, "exec", "--stdin", "--tty"]

        # Must be specified by subclasses
        self._curl_base = None

    def run_kubectl_command(self, cmd: list = None, opts: list = None) -> bytes:
        """
        Invokes a kubectl command in a pre-defined namespace.
        """
        if cmd is None:
            cmd = self._command_base

        if opts is None:
            opts = list()

        call_args = list([x for x in [*cmd, " ".join(opts)] if x])
        return utils.check_output(*call_args)

    def run_curl_command(self, curl_options) -> typing.Union[dict, bytes]:
        """
        Invokes a curl command on the first HarmonySearch pod.

        If possible returns the parsed json from the HarmonySearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        container = "harmony-search-cluster-master-0"
        response = self.run_kubectl_command(
            cmd=[*self._exec_command, container, "--", "bash", "-c"],
            opts=self._curl_base + curl_options,
        )

        try:
            return json.loads(response)
        except (TypeError, ValueError):
            return response

    def get_cluster_password(self, secret_name: str, field: str = "password") -> str:
        """
        Returns the search admin password for the cluster.

        Read the kubernetes opaque secret and return the value at the given
        `field` from the `secret_name`.
        """
        password = self.run_kubectl_command(
            [
                *self._command_base,
                "get",
                "secret",
                secret_name,
                "-o",
                f"jsonpath={{.data.{field}}}",
            ]
        )

        return base64.b64decode(password).decode()

    def get(self, endpoint):
        """
        Runs a GET request on the HarmonySearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the HarmonySearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_curl_command(["-XGET", f"https://localhost:9200/{endpoint}"])

    def post(self, endpoint: str, data: dict) -> typing.Union[dict, bytes]:
        """
        Runs a POST request on the HarmonySearch cluster with the specified
        endpoint.

        If possible returns the parsed json from the HarmonySearch response.
        Otherwise, the raw bytes from the curl command are returned.
        """
        return self.run_curl_command(
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
        return self.run_curl_command(
            [
                "-XPUT",
                f"https://localhost:9200/{endpoint}",
                "-d",
                f"'{json.dumps(data)}'",
                "-H",
                '"Content-Type: application/json"',
            ]
        )
