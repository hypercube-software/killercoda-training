helm repo add zipkin https://zipkin.io/zipkin-helm
helm install zipkin zipkin/zipkin \
  --create-namespace \
  --namespace monitoring

echo "Wait zipkin is ready..."
kubectl rollout status deployment/zipkin -n monitoring
echo "Zipkin is ready."
