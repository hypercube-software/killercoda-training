# Staged Build

Avant de poursuivre, j'aimerais insister sur la bonne et la mauvaise façon de faire des Dockerfile

Ce qu'on a fait précédemment est OK pour un tutoriel. Mais dans une CI, on utilisera plutôt un **Staged Build**
- On utilise Docker pour avoir un environment de build reproductible
- On utilise un "staged build" pour séparer cet environment du container final qu'on veut livrer

Concrètement, cela permet de builder notre microservice Java SANS embarquer l'environnement de build à la fin.
- Faire une image docker sans `stages` produit des images très lourdes, surtout en Java (jusqu'à 1GB)
- Cela augmente également la surface d'attaque, car il y a des outils de build dans l'image

Une mauvaise image de build contient qu'une directive `FROM`

```Dockerfile
FROM eclipse-temurin:26-jdk-alpine

WORKDIR /app

# Copie de l'intégralité du projet (sources, wrappers, pom.xml)
COPY . .

# Donner les droits d'exécution et télécharger les dépendances + compiler
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# Création d'un utilisateur non-root pour la sécurité
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080

# Exécution du JAR généré directement dans le dossier target
ENTRYPOINT ["java", "-jar", "target/demo-0.0.1-SNAPSHOT.jar"]
```

Générez l'image Docker comme pourrait le faire une CI avec `docker build -t microservice-java:v0 .`{{exec}}

Un `staged build` contient plusieurs directives `FROM`:

```Dockerfile
# --- Stage 1 : Build de l'application ---
FROM eclipse-temurin:26-jdk-alpine AS builder

WORKDIR /app

# Copie des fichiers de configuration Maven en premier (optimisation du cache Docker)
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Rendre le wrapper exécutable et télécharger les dépendances
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Copie des sources et compilation du JAR
COPY src ./src
RUN ./mvnw clean package -DskipTests

# --- Stage 2 : Image d'exécution minimale ---
FROM eclipse-temurin:26-jre-alpine

WORKDIR /app

# Création d'un utilisateur non-root pour la sécurité
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copie du JAR compilé depuis l'étape précédente
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

En utilisant cette technique, vous pouvez faire une CI qui forge des containers de façon professionnelle.

L'image finale ne contiendra jamais le repertoire `.m2` de maven par exemple.

Générez l'image Docker comme pourrait le faire une CI avec `docker build -t microservice-java:v1 .`{{exec}}

Executer `docker image ls`{{exec}} pour constater qu'elle fait 250MB contre 428MB

```
IMAGE                  ID             DISK USAGE   CONTENT SIZE   EXTRA
microservice-java:v0   5e7da72fd29c        428MB             0B        
microservice-java:v1   9f5171c78ae5        250MB             0B        
```

Installer notre image dans k8s avec :

`docker save microservice-java:v1 | ctr -n k8s.io images import -`{{exec}}


Tentez de repousser l'image avec : `kubectl run test-pod --image=microservice-java:v1 --image-pull-policy=IfNotPresent`{{exec}}
```
Error from server (AlreadyExists): pods "test-pod" already exists`
```

Bien évidemment, on ne peut pas écraser une image en cours d'utilisation.

Retirer notre pod avec : `kubectl delete pod test-pod`{{exec}}

Et retenter: `kubectl run test-pod --image=microservice-java:v1 --image-pull-policy=IfNotPresent`{{exec}}

