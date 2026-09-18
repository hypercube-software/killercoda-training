package com.example.demo.controller;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Component;

import java.lang.management.ManagementFactory;

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