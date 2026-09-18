Maintenant que Prometheus collecte nos données, on va monter d'un cran et installer Grafana

Grafana est l'outil de visualisation, de restitution et de tableaux de bord (dashboards) par excellence dans l'écosystème de l'observabilité.

Si on devait résumer la complémentarité entre Prometheus et Grafana :

- **Prometheus**:  Le moteur de collecte et de stockage. Il scrape les métriques, gère la base de données temporelle (TSDB) et évalue les règles d'alerte. Son interface web intégrée (port 9090) est basique, principalement conçue pour exécuter des requêtes PromQL rapides et du débogage.
- **Grafana**:  La vitrine et le cockpit. Il se connecte à Prometheus (et d'autres sources) pour transformer ces données brutes en graphiques modernes, interactifs et personnalisables.

# Installation

On peut installer Grafana dans k8s comme ceci :

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set sidecar.dashboards.enabled=false \
  --set sidecar.datasources.enabled=false \
  --set resources.requests.memory="64Mi" \
  --set resources.limits.memory="128Mi"
```

On pourra ensuite récupérer le password par default :

`kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`{{exec}}

Ca devrait remember à ça: `LJ9q4oznlBUNqVdEuXsGk0uXYoopNs7hnAYX1Tlc`

# IHM

Pour joindre l'IHM on fera un port forward :

`kubectl port-forward --address 0.0.0.0 -n monitoring svc/grafana 3000:80`{{exec}}

Se logger avec "admin" et le password

Une fois dans l'IHM, aller dans "Connections / Data source " dans le menu de gauche.

Puis "Add data source", choisir "Prometheus"

Il va falloir fournir l'URL de Prometheus, pour se faire, tapez :

`echo "http://$(kubectl get svc -n monitoring | grep -i 'prometheus' | grep -v 'alertmanager\|operator\|node-exporter\|grafana' | head -n1 | awk '{print $1}').monitoring.svc.cluster.local:$(kubectl get svc -n monitoring | grep -i 'prometheus' | grep -v 'alertmanager\|operator\|node-exporter\|grafana' | head -n1 | awk '{print $5}' | cut -d'/' -f1 | cut -d':' -f1)"`{{exec}}

Vous devriez avoir ceci :

```
http://prometheus-server.monitoring.svc.cluster.local:80
```

Renseigner cette URL dans "Connection" et faire "Save & Test"

Le message suivant devrait apparaitre:

```
Successfully queried the Prometheus API.
Next, you can start to visualize data by building a dashboard , or by querying data in the Explore view .
```

# Dashboard

Cliquez sur "building a dashboard" (ou allez dans le menu **Dashboard**) et créez un panel affichant notre métrique `app_uptime_seconds`

En bas, vous pouvez créer une query avec `app_uptime_seconds` et cliquer ensuite en haut sur "Refresh"

On ne va pas plonger dans Grafana, mais ça vous donne une idée. C'est cela qui compte dans ce tutoriel.

Dans l'étape suivante, on va revenir au code Java et aborder **Actuator**.


