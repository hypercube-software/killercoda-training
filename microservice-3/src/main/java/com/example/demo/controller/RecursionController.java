package com.example.demo.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;

import java.net.InetAddress;
import java.net.UnknownHostException;

@RestController
public class RecursionController {

    private static final Logger log = LoggerFactory.getLogger(RecursionController.class);

    @Value("${app.target-url}")
    private String targetUrl;

    private final RestClient restClient;
    private final String podIdentity;

    public RecursionController(RestClient restClient) {
        this.restClient = restClient;
        this.podIdentity = resolvePodIdentity();
    }

    @GetMapping("/recursive")
    public String handleRecursion(@RequestParam(defaultValue = "3") int count) {
        log.info("[Pod: {}] Étape courante - Compteur : {}", podIdentity, count);

        if (count <= 0) {
            return "Fin de la chaîne sur le pod : " + podIdentity;
        }

        int nextCount = count - 1;

        String response = restClient.get()
                .uri(targetUrl + "?count=" + nextCount)
                .retrieve()
                .body(String.class);

        return "[Étape " + count + " exécutée par " + podIdentity + "] -> \n" + response;
    }

    private String resolvePodIdentity() {
        try {
            InetAddress localHost = InetAddress.getLocalHost();
            return localHost.getHostName() + " (" + localHost.getHostAddress() + ")";
        } catch (UnknownHostException e) {
            return "Pod-Inconnu";
        }
    }
}
