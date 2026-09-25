
Installer Zipkin avec :

```
helm repo add zipkin https://zipkin.io/zipkin-helm
helm install zipkin zipkin/zipkin --namespace monitoring
```

Créer un port forward pour voir son IHM :
`kubectl port-forward svc/zipkin 9411:9411 -n monitoring`{{exec}}

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

`kubectl port-forward svc/demo-service 8080:8080`{{exec}}

`curl -s "http://localhost:8080/recursive?count=3"`{{exec}}

récupérer le pwd de Grafana avec :

`kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`{{exec}}

Pour joindre l'IHM on fera un port forward :

`kubectl port-forward --address 0.0.0.0 -n monitoring svc/grafana 3000:80`{{exec}}
