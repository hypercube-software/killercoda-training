# --- Stage 1 : Build de l'application ---
FROM eclipse-temurin:26-jdk-alpine AS builder

WORKDIR /app

# Copie des fichiers de configuration Maven en premier (optimisation du cache Docker)
COPY ../../../.mvn/ .mvn
COPY ../../../mvnw pom.xml ./

# Rendre le wrapper exécutable et télécharger les dépendances
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Copie des sources et compilation du JAR
COPY ../../../src ./src
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
