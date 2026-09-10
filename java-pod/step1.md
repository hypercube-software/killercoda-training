Vérifier que le microservice tourne correctement

Aller dans `/root/killercoda-training/microservice-1`

Executer `./mvnw spring-boot:run`

En haut à droite de l'interface KillerCoda aller dans Traffic/Ports

Cliquer sur Common Ports 8080

Et tester le endpoint `https://<your id>.killercoda.com/hello`

Il devrait retourner :
```
{"message":"Hello, World!","status":"success"}
```