from .base import BaseSearchAPI


class ElasticSearchAPI(BaseSearchAPI):
    """
    Helper class to interact with the ElasticSearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        super().__init__(namespace)
        cluster_password = self.get_cluster_password("elasticsearch-credentials")
        self._curl_base = ["curl", "--insecure", "-u", f"elastic:{cluster_password}"]
