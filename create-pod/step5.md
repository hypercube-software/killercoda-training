On va créer un descripteur de déploiement nous même

La commande `kubectl create deployment nginx-deployment --image=nginx` qu'on a utilisé précédemment en a fai tun à notre place.

Créer un fichier `deployment.yaml`

```yaml
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

Installer le descripteur avec :

`kubectl apply -f deployment.yaml`{{exec}}

Comme on a utilisé le label app `web` on peut faire :

`kubectl get pods -l app=web`{{exec}}

Il commence à y avoir du monde ! On voit les pods du premier descripteur de déploiement, et ceux du nôtre.

