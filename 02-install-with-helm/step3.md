Dans cette troisième étape, on va survoler un sujet très "devops" : les "opérateurs".

# Cela sert à quoi ?

Un "operator" est une sorte d'extension de k8s qui va être utilisée pour gérer une application complete comprenant plusieurs pods.
- Il installe de nouveaux types "Kind" dans le YAML
- Il gère le cycle de vie de l'application, un peu comme... un opérateur humain.
- En pratique, il n'est pas rare de voir un pod "opérateur" en plus de l'application.

# On en trouve où ?

On trouvera des tonnes d'opérateurs sur le site [https://operatorhub.io/](https://operatorhub.io/) qui a été initialement fondé par RedHat

# Limitations de KillerCoda

Malheureusement, vu la quantité de mémoire de nos VM sur killercoda, on ne pourra pas jouer avec ça.

# Comment ça s'installe ?

Typiquement avec helm :

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install my-operator prometheus-community/prometheus-operator
```

Où avec l'outil de RedHat [olm](https://olm.operatorframework.io/) :

```
# 1. Installer OLM sur le cluster (si ce n'est pas déjà fait)
operator-sdk olm install

# 2. Déployer un opérateur depuis OperatorHub via un fichier Subscription
kubectl apply -f subscription.yaml
```