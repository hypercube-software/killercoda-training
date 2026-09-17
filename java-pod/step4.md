# Helm setup

Aller dans le setup helm:

Executer `cd ~/killercoda-training/microservice-1/src/main/helm/simple`{{exec}}

On peut prévisualiser l'injection des values avec :

`helm template .`{{exec}}

On lance l'installation avec :

`helm install demo-java .`{{exec}}

On peut consulter les installations avec :

`helm list`{{exec}}

Vérifier que les 3 pods tournent:

`kubectl get pods -l app=web`{{exec}}

On peut désinstaller avec :

`helm uninstall demo-java`{{exec}}

Vérifier que les pods ne tournent plus :

`kubectl get pods -l app=web`{{exec}}

# Probes

On va aborder un sujet très important maintenant : les probes.
k8s offre 3 types de probes qu'on va implémenter dans notre microservice:
- **Startup Probe**: permet de savoir si l'application démarre ou est en vrac
- **Readiness Probe**: permet de savoir si l'application est bien démarrée et prête
- **Liveness Prove**: permet de savoir si l'application n'a pas crashée

Éditer le fichier `src/main/helm/simple/templates/deployment.yml` et rajouter :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: microservice-java
          image: microservice-java:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 8080

          # A. Startup Probe : 12 essais × 5 secondes = 60 secondes au total
          startupProbe:
            httpGet:
              path: /health/startup
              port: 8080
            failureThreshold: 12
            periodSeconds: 5

          # B. Readiness Probe : Retire le Pod des Endpoints du Service si échec
          readinessProbe:
            httpGet:
              path: /health/readiness
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 3

          # C. Liveness Probe : REDÉMARRE le conteneur si échec
          livenessProbe:
            httpGet:
              path: /health/liveness
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 3
```

Il faut maintenant implémenter ces trois endpoints coté java.
Faisons un `HealthController` :

```java
package com.example.demo.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

@RestController
public class HealthController {

    private boolean isHealthy = true;
    private boolean isReady = true;
    private boolean isStarted = false;

    // Simule la fin du démarrage de notre application (ex: chargement du cache)
    public HealthController() {
        new Thread(() -> {
            try {
                Thread.sleep(10000); // Démarrage simulé en 10 secondes
                this.isStarted = true;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();
    }

    // 1. Endpoint STARTUP Probe
    @GetMapping("/health/startup")
    public ResponseEntity<String> startup() {
        if (isStarted) return ResponseEntity.ok("STARTED");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("STARTING...");
    }

    // 2. Endpoint READINESS Probe
    @GetMapping("/health/readiness")
    public ResponseEntity<String> readiness() {
        if (isReady) return ResponseEntity.ok("READY");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("NOT_READY");
    }

    // 3. Endpoint LIVENESS Probe
    @GetMapping("/health/liveness")
    public ResponseEntity<String> liveness() {
        if (isHealthy) return ResponseEntity.ok("ALIVE");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("DEAD");
    }

    // --- Endpoints pour altérer l'état durant notre exercice ---

    @PostMapping("/act/toggle-ready")
    public String toggleReady() {
        this.isReady = !this.isReady;
        return "State isReady is now: " + this.isReady;
    }

    @PostMapping("/act/kill")
    public String killApp() {
        this.isHealthy = false;
        return "Application state is now DEAD";
    }
}
```

Rebuilder l'image (avec `no-cache`) :

`docker build --no-cache -t microservice-java:v1 -f src/main/Docker/Dockerfile .`{{exec}}

Updater note image dans k8s avec :

`docker save microservice-java:v1 | ctr -n k8s.io images import -`{{exec}}

Installer le YAML avec :

`helm install demo-java .`{{exec}}

Ou mettre à jour avec :

`helm upgrade demo-java .`{{exec}}

Constater avec k9s que les pods vont attendre 10 sec avant d'être READY 

Ensuite passer en isReady false :

`POD_IP=$(kubectl get pod -l app=web -o jsonpath='{.items[0].status.podIP}')`{{exec}}
`curl -X POST http://$POD_IP:8080/act/toggle-ready`{{exec}}

Constater avec k9s que l'un des pods repasse en NOT READY, refaire rapidement la requête pour revenir en READY

Ensuite on simule un crash, le pod ne réponds plus sur le liveness :

`curl -X POST http://$POD_IP:8080/act/kill`{{exec}}

Constater avec k9s que k8s redémarre le pod après l'avoir killé.

Désinstaller avec :

`helm uninstall demo-java`{{exec}}

