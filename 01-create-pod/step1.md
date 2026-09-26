Déjà voici comment lister les pods:

Run `kubectl get pod -A`{{exec}}

On peut faire un tunnel TCP vers le pod avec :

```
kubectl port-forward <ressource> <port-local>:<port-distant>
kubectl port-forward pod/POD_NAME 9411:9411
```

Sur killercoda, il faut en plus que ce tunnel écoute sur toutes les interfaces :

```
kubectl port-forward <ressource> <port-local>:<port-distant> --address 0.0.0.0
kubectl port-forward pod/POD_NAME 9411:9411 --address 0.0.0.0
```

On utilisera cela de façon intensive pour utiliser les IHM de certaines applications
