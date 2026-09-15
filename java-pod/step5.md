On va maintenant monter d'un cran: parlons networking dans k8s

# Compil Java 
si vous n'avez pas encore d'image docker `microservice-1` faire :
`docker build -t microservice-java:v1 -f src/main/Docker/Dockerfile .`{{exec}}

déployer l'image dans k8s avec:
`docker save microservice-java:v1 | ctr -n k8s.io images import -`{{exec}}

déployer le pod avec:
`helm install demo-java ./src/main/helm/simple/`{{exec}}

# Services

Un **Service** dans Kubernetes, c'est une adresse fixe et stable qui permet de joindre un ou plusieurs Pods.

Pourquoi c'est indispensable ?

- Les Pods sont éphémères : Ils démarrent, meurent, redémarrent, et à chaque fois leur adresse IP change.
- Le Service est permanent : Il possède un nom DNS (ex: microservice-1-service) et une IP virtuelle qui ne change jamais.
- Les règles de firewall (Ingress) ne peuvent pas marcher sans services.

# Types 

| Type de Service | Adresse accessible | Port utilisé | Usage principal |
| :--- | :--- | :--- | :--- |
| **`ClusterIP`** | Interne au cluster uniquement | Port du service (ex: `8080`) | Communication privée entre microservices |
| **`NodePort`** | `http://<IP-VM>:<NodePort>` | Port élevé (`30000-32767`) | Labs (KillerCoda), dev et tests directs |
| **`LoadBalancer`** | `http://<IP-Publique-Cloud>` | Ports standards (`80`, `443`) | Production sur Cloud Provider (AWS, GCP, etc.) |
| **`ExternalName`** | Redirection CNAME DNS | N/A | Pointer vers une BDD ou API externe au cluster |

# Créer un service

Créer le fichier `service.yml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-service
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 8080        # Port interne du Service
      targetPort: 8080  # Port de l'application dans le conteneur
      nodePort: 30080   # Port FIXE ouvert sur la VM hôte
```

Installer le service avec :
`kubectl apply -f service.yml`{{exec}}

Vérifier qu'il est là avec:
`kubectl get svc microservice-1-service`{{exec}}
ou avec k9s en faisant ":service"

On peut maintenant joindre le microservice via ce endpoint statique :

`curl http://localhost:30080/hello`{{exec}}

# Ingress

La touche finale consiste ensuite à exposer le microservice sur internet, malheureusement dans l'environnement Killercoda, on ne peut pas faire ça.

***NOTE***: En anglais, **ingress** est un mot de vocabulaire soutenu qui désigne l'action d'entrer quelque part ou un point d'accès/une entrée.

⚠ dans k8s, il existe deux concepts Ingress, ici, nous parlons du premier
- `Ingress`: en tant que resource "kind", relève du routage
- `ingress`: en tant que NetworkPolicy, relève de règle de firewall

Dans la vraie vie ça ressemble à ça :

```
[ Client / curl ]
       │
       ▼ (NodePort 31634)
[ Ingress Controller Nginx ] ──► (Valide le Host & la route /hello)
       │
       ▼ (Port 8080)
[ myweb-service ]
       │
       ▼ (IPs Pods 192.168.0.x)
[ Pod Spring Boot / Java ] ──► 200 OK !
```

Un controller "Ingress" est présent dans k8s et reçoit le traffic internet.
On va en installer un avec :

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/baremetal/deploy.yaml`{{exec}}

Attendre qu'il soit prêt avec :

`kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s`{{exec}}

On trouvera deux services dans son namespace:
`kubectl get svc -n ingress-nginx`{{exec}}

```
NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.110.32.184    <none>        80:31634/TCP,443:31717/TCP   14m
ingress-nginx-controller-admission   ClusterIP   10.100.137.127   <none>        443/TCP                      14m
```

Noter ici que le port HTTP 80 sera redirigé sur 31634, on va s'en servir.

On est presque en conditions réelles, on doit donc maintenant créer un "ingress" pointant sur notre "service".
Le point crucial pour que notre contrôleur détecte le service est de spécifier: `ingressClassName: nginx`
Il faut également "inventer" un hostname public, on prendra `myweb.killercoda.com`

Créer le fichier `ingress.yml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myweb-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: myweb.killercoda.com
    http:
      paths:
      - path: /hello
        pathType: Prefix
        backend:
          service:
            name: myweb-service
            port:
              number: 8080
```

Installer le service avec :
`kubectl apply -f ingress.yml`{{exec}}

On simule une requête internet avec le port qu'on a noté précédemment : 31634

`curl -H "Host: myweb.killercoda.com" http://localhost:31634/hello`{{exec}}

Cette requête arrive dans le contrôleur nginx, regarde le champ "Host" et le path "/hello" et trouve un "match" avec notre service fraichement créé.
La redirection s'opère et le flux HTTP est redirigé vers la cible : le "service" qui redirige ensuite vers l'un des pods

Constater qu'une requête sans Host n'est pas routée :

`curl http://localhost:31634/hello`{{exec}}

Vous pouvez désinstaller l'ingress pour constater que la requête ne passe plus

`kubectl delete ingress myweb-ingress`{{exec}}

ou

`kubectl delete -f ingress.yml`{{exec}}

Nginx répond :

```
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

# Network Policies

On monte encore d'un cran en complexité. Là, il s'agit de créer des règles de firewall.
- `ingress`, à ne pas confondre avec les `Ingress`: pour le traffic entrant
- `egress`, pour le traffic sortant

Exemple

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: springboot-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web  # Cible nos Pods Spring Boot
  policyTypes:
  - Ingress
  - Egress

  # 1. RÈGLES ENTRANTES (ingress)
  ingress:
  # Autorise uniquement le trafic provenant de l'Ingress Controller Nginx sur le port 8080
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080

  # 2. RÈGLES SORTANTES (egress)
  egress:
  # Autorise nos Pods à contacter CoreDNS pour la résolution de noms
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
  # Autorise nos Pods à contacter une base de données PostgreSQL interne sur le port 5432
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

# Exercice

Rajoutez l'ingress et le service à votre Chart Helm et testez l'installation.
(Utiliser k9s pour supprimer ce qu'on vient de créer)

