# Staged Build

Avant de poursuivre, j'aimerais insister sur la bonne et la mauvaise façon de faire des Dockerfile

Ce qu'on a fait précédemment est OK pour un tutoriel. Mais dans une CI, on utilisera plutôt un **Staged Build**

Concrètement, cela permet de builder notre microservice Java SANS embarquer l'environnement de build à la fin.
- Faire une image docker sans `stages` produit des images très lourdes, surtout en Java (jusqu'à 1GB)
- Cela augmente également la surface d'attaque, car il y a des outils de build dans l'image

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

Tentez de repousser l'image avec : `kubectl run test-pod --image=microservice-java:v1 --image-pull-policy=IfNotPresent`{{exec}}
```
Error from server (AlreadyExists): pods "test-pod" already exists`
```

Bien évidemment, on ne peut pas écraser une image en cours d'utilisation.

Retirer notre pod avec : `kubectl delete pod test-pod`{{exec}}
Et retenter: `kubectl run test-pod --image=microservice-java:v1 --image-pull-policy=IfNotPresent`{{exec}}

