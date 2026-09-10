Image Docker

# Build

Créer un fichier `Dockerfile` comme ceci :

```Dockerfile
FROM eclipse-temurin:26-jre-alpine

WORKDIR /app

# Copie du JAR directement depuis le dossier target/ local
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

Générez l'image Docker :
`docker build -t microservice-java:v1 .`{{exec}}

```
microservice-java  :  v1
└───────┬───────┘    └┬┘
Nom de l'image       Tag
```

Lancez le conteneur sur le port 8080 :
`docker run -d -p 8080:8080 --name my-app microservice-java:v1`{{exec}}

Vérifier comme on l'a fait précédemment que le endpoint marche

Arrêter le conteneur avec `docker stop my-app`{{exec}}

# Containerd

C'est peut-être une surprise pour certains d'entre vous, mais k8s n'utilise pas vraiment Docker !
Il utilise **containerd** qui était un sous composant interne de Docker, qui a ensuite été extrait pour devenir un projet autonome de la CNCF (**Cloud Native Computing Foundation**).
- Quand vous êtes sur votre PC, vous utilisez un service **dockerd** qui n'existe pas dans k8s
-  **dockerd** fait partie de ***Docker Desktop*** qui est un produit fermé de la société Docker.
- Dans k8s, la seule chose qui reste de Docker c'est le format des fichiers `Dockerfile`. Tout le reste est sorti de leur juridiction sous la forme de standards.
- `dockerd` et `containerd` suivent le standard OCI : **Open Container Initiative**

C'est un peu comme quand dans le monde anglophone, on parle d'une ***Xerox*** pour une photocopieuse alors que ce n'est plus du tout une ***Xerox***.

Ici, dans le monde k8s, cela fait bien longtemps qu'ils ont pris leurs distances avec la société Docker.

C'est grâce à l'OCI qu'on a pu voir se developer plusieurs CLI remplaçant la commande `docker`:
- podman
- nerdctl
- crictl
- ctr: c'est le CLI officiel minimaliste de `containerd` et on va s'en servir.
- Kanilo (Google)
- Buildah (Red Hat)
- Ko (CNCF)
- Jib (Google) : permet de builder une image avec Java sans démon Docker

D'ailleurs si vous installez sur votre PC **Rancher Desktop** au lieu de **Docker Desktop**, vous verrez que vous pouvez choisir de travailler avec **dockerd** ou **containerd** selon votre choix.

# ctr

Alors justement, on va utiliser maintenant `ctr` pour pousser notre image Docker dans k8s, et plus précisément dans `containerd`.

Installer le conteneur dans k8s avec :

`docker save microservice-java:v1 | ctr -n k8s.io images import -`{{exec}}

Noter qu'on pousse l'image vers le namespace `k8s.io` au lieu du default, car sur le default, on a uniquement nos trucs à nous.

Observer que l'image est installée :

`ctr -n k8s.io images list | grep microservice-java`{{exec}}

# Pull polices

Lancer temporairement un pod avec cette image :

`kubectl run test-pod --image=microservice-java:v1 --image-pull-policy=IfNotPresent`{{exec}}

La `pull policy` indique à k8s de "Télécharger l'image depuis le registre distant UNIQUEMENT si elle n'existe pas déjà sur la machine locale".

| Politique | Comportement de Kubernetes | Cas d'usage principal |
| :--- | :--- | :--- |
| **`IfNotPresent`** | Utilise l'image locale si elle existe. Sinon, la télécharge depuis le registre. | **Environnements de dev local**, images pré-chargées, optimisation de bande passante. |
| **`Always`** | Interroge le registre distant à **chaque démarrage** du Pod pour télécharger la toute dernière version. | **Production** (pour garantir l'exécution de la dernière version corrigée du tag). |
| **`Never`** | N'essaie **jamais** de télécharger l'image. Si elle n'est pas présente localement sur le nœud, le Pod échoue. | Strictement réservé aux images locales ou aux nœuds hors-ligne (*air-gapped*). |