On va créer un pod qui se recrée si il crash

Pour faire cela on va aborder le concept de Deployment descriptor.

Créer un fichier `hello-world-yaml.yml`

Executer `kubectl create deployment nginx-deployment --image=nginx`{{exec}}

Consulter les pods

Executer `kubectl get pods`{{exec}}

Cette fois-ci notre pod a pris un nom generique comme `nginx-deployment-7d6869886d-hk67r`

Utiliser k9s pour aller voir son YAML, on va découvrir que malgrès son nom, il a un label fixe:

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: nginx-deployment
```

La commande kubectl peut utiliser ces labels pour selectionner un ou plusieurs pods

Executer `kubectl get pods --selector=app=nginx-deployment`{{exec}}

On peut sortir en JSON

Executer `kubectl get pods --selector=app=nginx-deployment -o json`{{exec}}

On peut même faire du jsonpath

Executer `kubectl get pods --selector=app=nginx-deployment -o jsonpath='{.items[0].metadata.name}'`{{exec}}

Killer le pod

On peut donc killer notre pod de façon automatique comme ceci, malgrès son nonm générique

Executer `kubectl delete pod $(kubectl get pods --selector=app=nginx-deployment -o jsonpath='{.items[0].metadata.name}')`{{exec}}

Constater que cette fois-ci le pod renait de ses cendres, mais son nom a changé



