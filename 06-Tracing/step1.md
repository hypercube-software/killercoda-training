
Installer Zipkin avec :

```
helm repo add zipkin https://zipkin.io/zipkin-helm
helm install zipkin zipkin/zipkin \
  --create-namespace \
  --namespace monitoring
```

Créer un port forward pour voir son IHM :
`kubectl port-forward svc/zipkin 9411:9411 -n monitoring --address 0.0.0.0`{{exec}}

`cd /root/killercoda-training/microservice-3`{{exec}}

Compiler le microservice 3

`docker build --no-cache -t monitoring-java:v3 -f src/main/Docker/Dockerfile .`{{exec}}

Déployer l'image dans k8s avec :

`docker save monitoring-java:v3 | ctr -n k8s.io images import -`{{exec}}

déployer le pod avec:

`helm install demo-java ./src/main/helm/simple`{{exec}}

Redéployer avec différents paramètres :

```
helm upgrade --install demo ./src/main/helm/simple \
  --set replicaCount=4
```

Déclencher la recursion distribuée :

`kubectl port-forward svc/demo-service 8080:8080 --address 0.0.0.0`{{exec}}

`curl -s "http://localhost:8080/recursive?count=3"`{{exec}}

Aller dans l'IHM de Zipkin et observer les traces

Il est tout a fait possible de lui envoyer des traces fictives avec :

`
curl -i -X POST http://zipkin.monitoring.svc.cluster.local:9411/api/v2/spans -H "Content-Type: application/json" -d "[{\"traceId\":\"4bf92f3577b34da6a3ce929d0e0e4736\",\"id\":\"00f067aa0ba902b7\",\"name\":\"test-microsecondes\",\"timestamp\":$(date +%s)000000,\"duration\":12345,\"localEndpoint\":{\"serviceName\":\"mon-service-de-test\"}}]"
`{{exec}}
