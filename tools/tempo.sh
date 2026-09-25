helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install tempo grafana/tempo \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set target=all

echo "Wait tempo is ready..."
 kubectl rollout status deployment/tempo -n monitoring
echo "Tempo is ready.
