On va créer un pod qui se recrée si il crash

Pour faire cela on va aborder le concept de **Deployment descriptor** et de **ReplicaSet**.

# Créer le pod

Executer `kubectl create deployment nginx-deployment --image=nginx`{{exec}}

Consulter les pods

Executer `kubectl get pods`{{exec}}

Cette fois-ci notre pod a pris un nom générique comme `nginx-deployment-7d6869886d-hk67r`

Utiliser k9s pour aller voir son YAML, on va découvrir que malgré son nom, il a un label fixe :

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: nginx-deployment
```

La commande kubectl peut utiliser ces labels pour sélectionner un ou plusieurs pods

Executer `kubectl get pods --selector=app=nginx-deployment`{{exec}}

On peut sortir en JSON

Executer `kubectl get pods --selector=app=nginx-deployment -o json`{{exec}}

On peut même faire du jsonpath

Executer `kubectl get pods --selector=app=nginx-deployment -o jsonpath='{.items[0].metadata.name}'`{{exec}}

# Le ReplicatSet

Si vous regardez le YAML du premier pod et du second, vous allez voir que le second à un ReplicaSet de déclaré
```yaml
 ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet <=====================================
    name: nginx-deployment-7d6869886d
    uid: f0ea5271-1aad-4cac-9157-6e70d40f6302
  resourceVersion: "4473"
  uid: ade06524-64a6-41d0-930f-dd823b337fc5
```
C'est le réplicaSet qui permet de relancer un pod qui crash

Dans k9s taper ":" puis taper `replicaset` pour consulter les replicasets 

Comme d'habitude, utiliser "e" pour consulter le YAML

Observer que dans la section `spec` le nombre de replicas est 1

```yaml
spec:
    replicas: 1
```

Et qu'il y a une section `selector` utilisant les labels qu'on a découverts juste précédemment

```yaml
selector:
    matchLabels:
    app: nginx-deployment
    pod-template-hash: 7d6869886d
```

# Killer le pod

On peut killer notre pod de façon automatique comme ceci, malgré son nom générique:

Executer `kubectl delete pod $(kubectl get pods --selector=app=nginx-deployment -o jsonpath='{.items[0].metadata.name}')`{{exec}}

Constater que cette fois-ci le pod renait de ses cendres, mais son nom a changé

# Les Logs

Premiere constatation, lorsqu'un pod meurt, on perd ses logs. C'est un gros changement par rapport au monde des VM.
Kubernetes est fait comme ça, il faut l'accepter. Pour s'en sortir, on a souvent des systèmes pour collecter les logs des pods ailleurs et les persister en base.

# Deployment descriptor

On pourrait penser qu'il suffit de modifier le ReplicaSet pour qu'on puisse créer 2,3,4 pods du même genre.
En vrai, il faut passer par le deployment descriptor. Considerer le ReplicaSet comme un élément "read only".

Aller dans k9s et taper ":" puis "deploy"

On découvre qu'il existe un deployment descriptor `nginx-deployment`

Taper "e" pour consulter son YAML

Changer le nombre de replicas à **2**:

```yaml
spec:
    replicas: 2
```

Revenir aux pods et constater qu'on a maintenant 2 jolis pods qui tournent !

Revenir aux ReplicaSet et constater qu'il a maintenant changé avec un replicas à "2"

Conclusion:

Le deployment descriptor est celui qui "drive" la vie d'un pod.
- il spécifie l'image docker à utiliser
- il spécifie si il faut utiliser un ReplicaSet
- il peut même overrider les commandes du container lors de son démarrage

On va maintenant faire notre propre descripteur de deploiement en YAML
