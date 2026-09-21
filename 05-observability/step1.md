Vérifier que le microservice tourne correctement

Aller dans le repertoire du SECOND microservice Java 

Executer `cd /root/killercoda-training/microservice-2`{{exec}}

Executer `./mvnw spring-boot:run`{{exec}}

En haut à droite de l'interface KillerCoda aller dans Traffic/Ports

Cliquer sur Common Ports 8080

Et tester le endpoint `https://<your id>.killercoda.com/metrics`

Il devrait retourner des données au format Prometheus :
```
{"message":"Hello, World!","status":"success"}
```
`docker build --no-cache -t monitoring-java:v1 -f src/main/Docker/Dockerfile .`{{exec}}

Déployer l'image dans k8s avec :

`docker save monitoring-java:v1 | ctr -n k8s.io images import -`{{exec}}

déployer le pod avec:

`helm install demo-java ./src/main/helm/simple/`{{exec}}

