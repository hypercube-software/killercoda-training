Déjà voici comment lister les pods:

Run `kubectl get pod -A`{{exec}}

On peut faire un tunel TCP vers le pod avec :

```
kubectl port-forward <ressource> <port-local>:<port-distant>
kubectl port-forward pod/POD_NAME 9411:9411
```

On utilisera cela de façon intensive pour utiliser les IHM de certaines applications
