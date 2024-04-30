from .base import BaseSearchAPI


class OpenSearchAPI(BaseSearchAPI):
    """
    Helper class to interact with the OpenSearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        super().__init__(namespace)
        cluster_password = self.get_cluster_password("opensearch-credentials")
        self._curl_base = ["curl", "--insecure", "-u", f"harmony:{cluster_password}"]
