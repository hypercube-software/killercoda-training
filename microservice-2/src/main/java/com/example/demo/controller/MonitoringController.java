package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MonitoringController {

    // Horodatage du démarrage de l'application
    private final long startTime = System.currentTimeMillis();

    // Endpoint réservé au scraping de Prometheus (Plain Text)
    @GetMapping(value = "/metrics", produces = "text/plain; version=0.0.4; charset=utf-8")
    public String customPrometheusMetrics() {
        StringBuilder sb = new StringBuilder();

        // Calcul de l'uptime actuel en secondes
        long uptimeInSeconds = (System.currentTimeMillis() - startTime) / 1000;

        sb.append("# HELP app_uptime_seconds Temps d'execution du microservice en secondes\n");
        sb.append("# TYPE app_uptime_seconds gauge\n");
        sb.append("app_uptime_seconds ").append(uptimeInSeconds).append("\n");

        return sb.toString();
    }
}