On va créer un pod depuis une image docker avec notre propre YAML

Créer un fichier `hello-world-yaml.yml`

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

Executer `kubectl apply -f hello-world-yaml.yml`{{exec}}

Consulter les pods

Executer `kubectl get pods`{{exec}}

Killer le pod

Executer `kubectl delete pod hello-world-yaml`{{exec}}

On va maintenant faire en sorte qu'un pod se recrée tout seul si il crash

