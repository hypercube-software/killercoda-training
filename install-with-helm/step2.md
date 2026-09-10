Dans cette seconde étape, on va explorer les "values"

# Les Values

C'est tout simplement une façon de paramétriser un setup.
Comme exemple, on va paramétriser le nombre de replicas.

Créer un fichier `mon-app/values.yaml` (et pas `mon-app/values.yml` !)

```yaml
replicaCount: 3
```

Modifier le descripteur de déploiement dans `mon-app/templates/deployment.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

La distribution devrait ressembler à :

```
mon-app/
├── Chart.yaml
├── values.yaml
└── templates/
    └── deployment.yaml
```
On peut prévisualiser l'injection des values avec :

`helm template ./mon-app`{{exec}}

On lance l'installation avec :

`helm install demo-release ./mon-app`{{exec}}

On peut consulter les installations avec :

`helm list`{{exec}}

Vérifier que les 3 pods tournent:

`kubectl get pods -l app=web`{{exec}}

On peut désinstaller avec :

`helm uninstall demo-release`{{exec}}

Vérifier que les pods ne tournent plus :

`kubectl get pods -l app=web`{{exec}}

# Aller plus loin

Helm c'est juste un moteur de template.

Il fournit des valeurs prédéfinies comme :
```yaml
{{ .Chart.Name }}
{{ .Release.Name }}
{{ .Release.Service }}
```

Il peut faire des conditions comme :

```yaml
containers:
      - name: nginx
        image: nginx:latest
{{- if .Values.sidecar.enabled }}
      - name: log-exporter
        image: busybox
        command: ['sh', '-c', 'while true; do echo logging; sleep 5; done']
{{- end }}
```

Il peut faire des includes comme `mon-app/templates/_helpers.tpl` :

```yaml
{{/* Génère des labels communs réutilisables partout */}}
{{- define "mon-app.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
env: {{ .Values.environment | default "dev" }}
{{- end -}}
```
Qu'on injecte avec :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    {{- include "mon-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        {{- include "mon-app.labels" . | nindent 8 }}
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

Cela devient de plus en plus complexe quand on passe des paramètres aux includes :

```yaml
metadata:
  name: web-deployment
  labels:
    {{- include "mon-app.customLabels" (dict "role" "frontend" "context" .) | nindent 4 }}
```

La fonction `dict` permet de créer un objet à la volée qu'on pourrait décrire en JSON par:
```json
{
  "role": "frontend",
  "context": {
      /*...contexte du moteur helm..*/
  }
}
```

La fonction `nindent 4` est cruciale pour générer du YAML valide. Sans elle on aurait ça:
```yaml
metadata:
  name: web-deployment
  labels:
    app.kubernetes.io/name: mon-app
app.kubernetes.io/instance: demo-release
```

Il n'y a qu'une règle importante à comprendre :

Le fichier **Values.yaml** ne peut pas lui-même être une template.

- Impossible d'utiliser `{{ .Values.foo }}` dans le fichier des values
- C'est voulu. Helm fait une separation stricte données vs. logique.
- Au cœur de ce choix, on trouve le concept de la **reproductibilité d'un build** cher aux CI/CD.
- C'est une approche très fonctionnelle qu'on retrouve un peu partout dans k8s (une même entrée produit toujours la même sortie).
