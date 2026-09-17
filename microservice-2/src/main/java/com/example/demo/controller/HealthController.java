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
                Thread.sleep(1000); // Démarrage simulé en 1 secondes
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