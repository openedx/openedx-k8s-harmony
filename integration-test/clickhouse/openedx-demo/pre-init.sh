export HARMONY_NAMESPACE=$(tutor config printvalue K8S_HARMONY_NAMESPACE)
kubectl apply -f clickhouse-keeper.yml -n "$K8S_HARMONY_NAMESPACE" --wait
kubectl apply -f clickhouse-installation.yml -n "$K8S_HARMONY_NAMESPACE" --wait
