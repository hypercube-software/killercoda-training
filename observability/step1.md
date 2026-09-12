Vérifier que le microservice tourne correctement

Aller dans le repertoire du microservice Java (il a déjà été compilé)

Executer `cd /root/killercoda-training/microservice-1`{{exec}}

Executer `./mvnw spring-boot:run`{{exec}}

En haut à droite de l'interface KillerCoda aller dans Traffic/Ports

Cliquer sur Common Ports 8080

Et tester le endpoint `https://<your id>.killercoda.com/hello`

Il devrait retourner :
```
{"message":"Hello, World!","status":"success"}
```