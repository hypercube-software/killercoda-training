Spring Boot Actuator est un module officiel de Spring Boot qui ajoute automatiquement des fonctionnalités d'observabilité et de gestion en production à une application, sans qu'il soit nécessaire d'écrire du code à la main.

Là où nous avons dû coder manuellement des contrôleurs Java pour /health et /metrics, Actuator fournit ces fonctionnalités prêtes à l'emploi (out-of-the-box).

# Les 3 apports principaux d'Actuator

## Des endpoints d'infrastructure pré-définis

En ajoutant simplement la dépendance spring-boot-starter-actuator, l'application expose automatiquement des points d'entrée HTTP (sous le préfixe /actuator) :

- `/actuator/health` : Indique l'état de santé global de l'application (et peut vérifier automatiquement les connexions aux bases de données, à Kafka, etc.).

- `/actuator/prometheus` : Expose toutes les métriques système et applicatives directement au format texte compatible avec Prometheus.

- `/actuator/info` : Donne des informations sur le build, la version Git, etc.

- `/actuator/env` ou `/loggers` : Permet de consulter la configuration ou de changer le niveau de log à chaud sans redémarrer l'application.

## Intégration native avec Micrometer

Actuator s'appuie sur Micrometer (l'équivalent de SLF4J mais pour les métriques). Cela permet de collecter automatiquement et sans effort des dizaines de métriques système :

- Utilisation de la mémoire JVM (Heap, Non-Heap, Garbage Collector).

- Utilisation du CPU et nombre de threads.

- Statistiques HTTP (temps de réponse, nombre de requêtes 200, 404, 500 via http.server.requests).

- Pools de connexions de base de données (HikariCP).

## Customisation facile pour Kubernetes

Actuator gère nativement le découpage exigé par Kubernetes pour les sondes :

- `/actuator/health/liveness` (pour la Liveness Probe).
- `/actuator/health/readiness` (pour la Readiness Probe).

Noter qu'ils ont décidé d'utiliser **liveness** également pour la sonde startup.

# Pom.xml

rajouter cela dans votre pom :

```xml
    <!-- Spring Boot Actuator -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>

    <!-- Export des métriques au format Prometheus -->
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
```

# Configuration

Rajouter ceci dans votre configuration :

```
# Exposer l'endpoint Prometheus et les endpoints de santé
management.endpoints.web.exposure.include=health,prometheus

# Activer la gestion native des sondes Liveness/Readiness pour Kubernetes
management.health.probes.enabled=true

# (Optionnel) Afficher les détails du health check
management.endpoint.health.show-details=always
```

Modifier votre descripteur de déploiement, car les url des endpoints changent :

- `/metrics` devient `/actuator/prometheus`
- `/health/liveness` devient `/actuator/health/liveness`
- `/health/readiness` devient `/actuator/health/readiness`
- `/health/startup` sera le même que liveness. Il devient `/actuator/health/liveness` 

`Retirer la classe `HealthController`

# Metrics

On va maintenant remplacer notre MonitoringController "maison" en utilisant l'API **Metrics**:

Remplacer la classe par celle-ci :

```java
package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Component
public class MetricsConfig {

    // Horodatage du démarrage de l'application
    private final long startTime = System.currentTimeMillis();

    public MetricsConfig(MeterRegistry registry) {
        // Enregistrement de la Gauge Micrometer basée sur votre variable startTime
        Gauge.builder("app_uptime_seconds", () -> (System.currentTimeMillis() - this.startTime) / 1000.0)
                .description("Temps d'exécution du microservice en secondes")
                .register(registry);
        // Enregistre la métrique custom app_uptime_seconds dans le registre Micrometer
        Gauge.builder("app_uptime_seconds_v2", () -> ManagementFactory.getRuntimeMXBean().getUptime() / 1000.0)
                .description("Temps d'exécution du microservice en secondes")
                .register(registry);
    }
}
```

On expose notre `app_uptime_seconds` mais on va également exposer `app_uptime_seconds_v2` pour illustrer une variante.

`app_uptime_seconds_v2` utilise l'API du JDK `ManagementFactory` pour calculer le uptime.

# Dashboard

Grafana fournit des dashboards à partir de leur ID. Le 4701 est celui de **JVM Micrometer**. 

Aller dans le menu Dashboard, faire **New** puis **Import** et entrer le numéro **4701**. Faire **Load**.

Je vous laisse contempler cette merveille...

En haut dans le menu "Instance" vous pourrez voir nos 2 pods.

Vous pouvez faire votre propre dashboard avec ces requetes:

## Mémoire Heap

```
jvm_memory_used_bytes{area="heap", app="web"} / 1024 / 1024
```

## Nombre de threads actifs

```
jvm_threads_live_threads{app="web"}
```

## Conso CPU

```
process_cpu_usage{app="web"} * 100
```

## GC

```
rate(jvm_gc_pause_seconds_count{app="web"}[5m])
```
