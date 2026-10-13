On aborde maintenant un concept très important en k8s: les configmaps.

# But d'un Configmap

Un configmap permet d'injecter une configuration dans un pod.
- on peut injecter des variables d'environnement
- on peut injecter des fichiers dans le container docker

Mais attention, un configmap peut vite de venir gros et atteindre **sa limite de 1Mo**.
Cette limite vient du fait que k8s stocke ses objets (Pods, Services, ConfigMaps, etc.) dans sa base de données interne : **etcd**.
- **etcd** est optimisé pour stocker des métadonnées de configuration légères.
- Mettre une limite stricte à 1 Mo évite qu'un utilisateur ne stocke par erreur (ou par abus) des fichiers massifs, des dumps de bases de données, des binaires ou de gros fichiers de logs dans un ConfigMap, ce qui ralentirait ou saturerait etcd.

Lorsque les configurations sont trop grosses, on utilisera plutôt du serveur dédié comme [Spring Coud Config](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/), [HashiCorps Vault](https://www.hashicorp.com/en/products/vault) ou [Consul](https://developer.hashicorp.com/consul).

# Premier Configmap

Nous allons créer un configmap de nom `app-config ` dans un fichier `configmap.yaml` :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.message: "Hello from Kubernetes ConfigMap"  
```

le déployer avec: `kubectl apply -f configmap.yaml`{{exec}}

Note: il existe des variantes plus ou moins utiles pour en créer un :
- `kubectl create configmap java-app-config --from-file=application.properties`
- `kubectl create configmap java-app-config --from-literal=app.message="Hello" --from-literal=server.port="8080"`

# Utiliser le config map

Le configmap est utilisé par le descripteur de déploiement de plusieurs manières :

## Avec `valueFrom`

```yaml
env:
  - name: APP_MESSAGE
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: app.message
```

## Avec `envFrom`

```yaml
envFrom:
  - configMapRef:
    name: app-config
```

## Avec un volume

```yaml
volumes:
    - name: config-volume
      configMap:
        name: app-config
```

Dans ce cas ce n'est pas configmap qui est monté, mais toutes ses entrées `data`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: java-app-config
data:
  application.properties: |
    # Configuration de l'application Java
    server.port=8080
    app.message=Hello depuis le fichier ConfigMap monté en volume !
    app.feature.toggle=true
    spring.datasource.url=jdbc:postgresql://postgres-db:5432/mydb
```

# SpringBoot

Springboot offre une logique de chargement de propriétés qui est parfaite pour un usage k8s. 
Elle repose sur un ordre de priorité qu'il faut connaitre.

Du plus bas au plus haut :

- les fichiers du jar, typiquement `src/main/resources/application.properties`
- les fichiers hors du jar, typiquement `./config/application.properties`
- les variables d'environnement
- les arguments en ligne de commande

Avec les équivalences suivantes :

- `APP_MESSAGE` ou `app_message`pour les variables d'environement
- `app.message` dans les properties
- `@Value("${app.message}")` dans le code Java

# Exercice

Executer `cd ~/killercoda-training/microservice-1`{{exec}}

Rebuilder l'image (avec `no-cache`) :

`docker build --no-cache -t microservice-java:v1 -f src/main/Docker/Dockerfile .`{{exec}}

Updater note image dans k8s avec :

`docker save microservice-java:v1 | ctr -n k8s.io images import -`{{exec}}

Si ce n'est pas déjà fait, désinstaller le helm actuel :

Executer `helm uninstall demo-java `{{exec}}

j'ai préparé un second setup helm dans '/src/main/helm/configmap'

Executer `cd ~/killercoda-training/microservice-1/src/main/helm/configmap`{{exec}}

On lance l'installation avec :

`helm install demo-java .`{{exec}}

On a testé nos endpoints avec l'IP d'un pod mais on va faire différemment cette fois-ci
```
POD_IP=$(kubectl get pod -l app=web -o jsonpath='{.items[0].status.podIP}')
curl -X GET http://$POD_IP:8080/message`
```

On va faire un **port forward** sur notre descripteur de déploiement `web-deployment`:

Executer `kubectl port-forward deployment/web-deployment 8080:8080`{{exec}}

Executer `curl http://localhost:8080/message`{{exec}}

Avec k9s, modifier le message du config map et voir ce qu'il se passe (utiliser la commande `:configmap`)

Executer `kubectl rollout restart deployment/web-deployment`{{exec}} pour relancer les pods

Executer `curl http://localhost:8080/message`{{exec}}

Conclusion: le config map n'est pris en compte qu'au démarrage d'un pod. Aucune mise à jour à chaud n'est possible.

# Helm

Sachant qu'on peut injecter un fichier dans un configmap, il vient tout naturellement l'idée de le faire avec Helm.

On peut faire cela :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    app: web
data:
  # Le nom de la clé qui deviendra ton fichier ou ta propriété
  application.properties: |
{{ .Files.Get "resources/application.properties" | indent 4 }}
```

Helm va inclure le fichier directement dans le configmap tout en faisant TRES ATTENTION à l'indentation.
