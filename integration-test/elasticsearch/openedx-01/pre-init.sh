export HARMONY_NAMESPACE=$(tutor config printvalue K8S_HARMONY_NAMESPACE)
export INSTANCE_NAMESPACE=$(tutor config printvalue K8S_NAMESPACE)
tutor harmony create-elasticsearch-user

kubectl get secret "search-cluster-certificates-elasticsearch" -n "$HARMONY_NAMESPACE" -o "yaml" | \
    grep -v '^\s*namespace:\s' | \
    sed s/-elasticsearch//g |\
    kubectl apply -n "$INSTANCE_NAMESPACE" --force -f -
