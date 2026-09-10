On va créer un pod depuis une image docker avec notre propre YAML

Créer un fichier `hello-world.yml`

```
apiVersion: v1
kind: Pod
metadata:
  name: hello-world-yaml
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

Executer `kubectl apply -f hello-world.yml`{{exec}}

Consulter les pods

Executer `kubectl get pods`{{exec}}

Si vous êtes rapide, vous allez voir 0/1
```
NAME               READY   STATUS              RESTARTS   AGE
hello-world-yaml   0/1     ContainerCreating   0          3s
```
Puis à un moment le pod sera prêt
```
NAME               READY   STATUS              RESTARTS   AGE
hello-world-yaml   1/1     ContainerCreating   0          3s
```

Killer le pod

Executer `kubectl delete pod hello-world-yaml`{{exec}}

On va maintenant faire en sorte qu'un pod se recrée tout seul si il crash

