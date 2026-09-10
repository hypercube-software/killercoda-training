On va d'abord créer un pod depuis une image docker sans YAML

Pour ce faire, on va utiliser le "hello world" du serveur web nginx:

Run `kubectl run hello-world --image=nginx`{{exec}}

Vérifier le status du pod:

Run `kubectl get pods`{{exec}}

Inspecter les détails du pod:

Run `kubectl describe pod hello-world`{{exec}}

Tester l'accès au pod:

```
POD_IP=$(kubectl get pod hello-world -o jsonpath='{.status.podIP}')
curl $POD_IP
```{{exec}}