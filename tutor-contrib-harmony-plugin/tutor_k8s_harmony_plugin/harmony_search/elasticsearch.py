from .base import BaseSearchAPI


class ElasticSearchAPI(BaseSearchAPI):
    """
    Helper class to interact with the ElasticSearch
    API on the deployed cluster.
    """

    def __init__(self, namespace):
        super().__init__(namespace)
        self._curl_base = ["curl", "--insecure", "-u", "elastic:${ELASTIC_PASSWORD}"]
