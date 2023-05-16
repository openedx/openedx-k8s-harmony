from .base import BaseSearchAPI


class OpenSearchAPI(BaseSearchAPI):
    """
    Helper class to interact with the OpenSearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        super().__init__(namespace)
        # TODO: Make this configurable
        self._curl_base = ["curl", "--insecure", "-u", "harmony:${HARMONY_PASSWORD}"]
