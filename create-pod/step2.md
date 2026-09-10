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
```

Utiliser k9s pour inspecter le cluster

Run `k9s`{{exec}}

Selectionner notre pod et faire ENTER, on va dans le detail du container

Faire à nouveau ENTER, on entre dans le log du container

Faire ESC deux fois pour revenir au pod

Daire "e" pour voir son descripteur YAML

On va maintenant recommancer en faisant notre propre descripteur...
