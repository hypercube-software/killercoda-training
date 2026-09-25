helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install grafana grafana/grafana \
  --namespace monitoring \
  --set admin.password=admin \
  --set persistence.enabled=false \
  --set sidecar.dashboards.enabled=false \
  --set sidecar.datasources.enabled=false \
  --set resources.requests.memory="64Mi" \
  --set resources.limits.memory="128Mi"

echo "Wait Grafana is ready..."
kubectl rollout status deployment/grafana -n monitoring --timeout=120s

echo "Grafana is ready."
