La première étape pour faire un setup Helm est de créer une distribution

Run `mkdir -p mon-app/templates`{{exec}}

Créer un fichier `Chart.yaml` dans le repertoire `mon-app`

```
apiVersion: v2
name: mon-app
description: Mon premier Chart Helm sur Killercoda
type: application
version: 0.1.0
appVersion: "1.0.0"
```

Créer ensuite un descripteur de déploiement dans `mon-app/templates/deployment.yml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: 2
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

La distribution devrait ressembler à:

```
mon-app/
├── Chart.yaml
└── templates/
    └── deployment.yaml
```

On lance l'installation avec :

`helm install demo-release ./mon-app`{{exec}}

On peut consulter les installations avec :

`helm list`{{exec}}

Vérifier que les pods tournent:

`kubectl get pods -l app=web`

On peut désinstaller avec :

`helm uninstall demo-release`{{exec}}