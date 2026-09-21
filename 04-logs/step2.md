On va maintenant installer Grafana et le connecter à Loki

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace \
  --set alertmanager.enabled=true \
  --set prometheus-node-exporter.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set kube-state-metrics.enabled=false \
  --set server.resources.requests.memory="128Mi" \
  --set server.resources.limits.memory="256Mi"
```

Récupérer le password de l'IHM avec: 

`kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`{{exec}}

Créer une data source de type LOKI

- Aller dans le menu à gauche, ouvrir Connection/Data sources
- Au moment de créer une data source Loki, spécifier cette url: `http://loki-headless:3100`
- Faire Save & Test
- Aller dans Explore
- Rechercher des logs avec `app = web`
- Contempler le résultat

Grafana devrait voir si vous loggez en JSON, dans ce cas, il est possible de rajouter des filtres JSON
Ceci dit ce n'est pas en JsonPath, c'est du LogQL, le langage de request age de Loki.

Déposer cette requête LogQL dans l'IHM :

```
{app="web"} | json | log_logger = `com.example.demo.DemoApplication`
```

Cliquez sur "Run query" pour rafraichir.

