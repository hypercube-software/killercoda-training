helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Déployer Loki avec le schema de test (sans persistance)
helm install loki grafana/loki \
  --namespace monitoring \
  --create-namespace \
  --set deploymentMode=SingleBinary \
  --set singleBinary.replicas=1 \
  --set loki.useTestSchema=true \
  --set loki.auth_enabled=false \
  --set loki.commonConfig.replication_factor=1 \
  --set loki.storage.type=filesystem \
  --set read.replicas=0 \
  --set write.replicas=0 \
  --set backend.replicas=0 \
  --set chunksCache.enabled=false \
  --set resultsCache.enabled=false \
  --set resources.requests.memory="128Mi" \
  --set resources.limits.memory="256Mi"

echo "Wait loki is ready..."
kubectl rollout status statefulset/loki -n monitoring --timeout=120s
echo "loki is ready."

# 2. Déployer Promtail pour collecter les logs des Pods K8s
helm install promtail grafana/promtail \
  --namespace monitoring \
  --set config.clients[0].url="http://loki:3100/loki/api/v1/push" \
  --set resources.requests.memory="32Mi" \
  --set resources.limits.memory="64Mi"

echo "Wait promtail is ready..."
kubectl rollout status daemonset/promtail -n monitoring --timeout=120s

echo "promtail is ready."
