# Métriques

On va regarder l'IHM de Prometheus et faire un peu de PromQL

Rendre accéssible le port de l'IHM avec :

`kubectl port-forward svc/prometheus-server -n monitoring 9090:80 --address 0.0.0.0`{{exec}}

Aller en haut à droite dans le menu de killer-coda "Traffic/Port" et aller sur 9090

Cliquer sur **Graph**

Taper la requête PromQL suivante : `app_uptime_seconds`

Observer les "escaliers": cela vient du fait que Prometheus inspecte notre microservice **toutes les 30 secondes**

On peut aussi faire un CURL sur Prometheus comme ceci :

`curl -s "http://localhost:9090/api/v1/query?query=app_uptime_seconds" | jq`{{exec}}

# Alertes

On peut pousser des alertes avec un peu de Helm. 

Créer le fichier `prometheus-rules.yaml` :

```yaml
serverFiles:
  alerting_rules.yml:
    groups:
      - name: microservice_alerts
        rules:
          # 1. Alerte si le Pod vient de redémarrer (Uptime < n sec)
          - alert: MicroservicePodRestarted
            expr: app_uptime_seconds < 1000
            for: 10s
            labels:
              severity: warning
            annotations:
              summary: "Le Pod {{ $labels.pod }} a redémarré récemment"
              description: "L'uptime du pod {{ $labels.pod }} est de {{ $value }}s (inférieur à 60s)."

          # 2. Alerte si Prometheus n'arrive plus à scraper le Pod (Pod mort/inaccessible)
          - alert: MicroserviceTargetDown
            expr: up{job="kubernetes-pods", app="web"} == 0
            for: 15s
            labels:
              severity: critical
            annotations:
              summary: "Le Pod {{ $labels.pod }} ne répond plus au scraping"
              description: "La cible {{ $labels.instance }} est DOWN."
```

Et lancer :

`helm upgrade prometheus prometheus-community/prometheus \
  --namespace monitoring \
  -f prometheus-rules.yaml \
  --reuse-values`{{exec}}

Attendre un petit peu pour que ça se charge et aller dans **Alerts** dans l'IHM de Prometheus.
Vous devriez en voir 2 (Inutile de rafraichir la page, ça se fait tout seul)

L'alerte `app_uptime_seconds < 1000` devrait s'exécuter bientôt si ce n'est pas déjà fait.
- Une alerte commence en état INACTIVE
- Si la condition est remplie, elle passe en PENDING pour 10 secondes (car nous avons mis `for: 10s`)
- Ensuite, elle devrait passer en FIRING puis revenir en INACTIVE

On peut jouer à désinstaller nos pods avec `helm uninstall demo-java`{{exec}}

Constater que la seconde alerte ne se met même pas en PENDING. C'est normal, mais c'est un peu déroutant :
- La requête `up{job="kubernetes-pods", app="web"} == 0` est censé trouver des pods déclarés, mais morts (YAML présent)
- Hors, nous avons désinstallé notre YAML donc, il n'y a rien alerter.

# Question

Pourquoi on ne verra jamais l'alerte 2 ?

