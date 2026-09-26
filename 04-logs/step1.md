La collecte de log se fait souvent avec 2 outils de Grafana Labs: Loki et Promtail
- Promtail à pour but de collecter les logs
- Loki à pour but de les stoquer

# Deployer le java

Si ce n'est pas déjà fait, déployez `microservice-2`

```
cd /root/killercoda-training/microservice-2
docker build --no-cache -t monitoring-java:v1 -f src/main/Docker/Dockerfile .
docker save monitoring-java:v1 | ctr -n k8s.io images import -
helm install demo-java ./src/main/helm/simple/
```

# Installation

Installer ces outils avec :

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Déployer Loki avec le schema de test (sans persistance)
helm install loki grafana/loki \
  --namespace monitoring \
  --create-namespace \
  --set deploymentMode=SingleBinary \
  --set singleBinary.replicas=1 \
  --set loki.useTestSchema=true \
  --set loki.auth_enabled=false \
  --set loki.commonConfig.replication_factor=1 \
  --set loki.storage.type=filesystem \
  --set read.replicas=0 \
  --set write.replicas=0 \
  --set backend.replicas=0 \
  --set chunksCache.enabled=false \
  --set resultsCache.enabled=false \
  --set resources.requests.memory="128Mi" \
  --set resources.limits.memory="256Mi"
  

# 2. Déployer Promtail pour collecter les logs des Pods K8s
helm install promtail grafana/promtail \
  --namespace monitoring \
  --set config.clients[0].url="http://loki:3100/loki/api/v1/push" \
  --set resources.requests.memory="32Mi" \
  --set resources.limits.memory="64Mi"
```

Normalement on consulte les logs dans Grafana, mais pour faire simple on utilisera logcli qui est une petite interface CLI pour Loki (qui n'a pas d'interface web)

```
# 1. Télécharger la dernière version stable de logcli (Linux x86_64)
curl -O -L https://github.com/grafana/loki/releases/download/v3.0.0/logcli-linux-amd64.zip

# 2. Décompresser l'archive
unzip logcli-linux-amd64.zip

# 3. Rendre le binaire exécutable et le déplacer dans le PATH du système
chmod +x logcli-linux-amd64
mv logcli-linux-amd64 /usr/local/bin/logcli

# 4. Nettoyer l'archive zip
rm logcli-linux-amd64.zip
```

# Consultation

Tester les logs avec :

`kubectl port-forward svc/loki 3100:3100 -n monitoring --address 0.0.0.0`{{exec}}

`export LOKI_ADDR=http://localhost:3100`{{exec}}

`logcli query -f '{app="web"}'`{{exec}}

On pourra utiliser k9s, pour descendre `replicas` à "0", et constater qu'on peut toujours consulter les logs alors qu'il n'y a plus de pods

# Perspectives

## Les stacks

Évidemment **Loki** n'est pas la seule stack pour les logs. 
- **Splunk**: payant avec une empreinte mémoire lourde
- **Elastic**: Open source, mais toujours avec un empreinte mémoire lourde
- **Loki**: Open source, empreinte mémoire très faible

## Les logs

Il est parfois utile de logger en JSON au lieu d'un texte brut, même si Loki n'impose rien.

En SpringBoot 3.1+ on peut faire cela :

```
# Active la sortie JSON sur stdout
logging.structured.format.console=ecs
```

**ecs** correspond au format standard Elastic Common Schema. Vous pouvez aussi utiliser **gelf** ou **logstash** selon les besoin

exemple:

```json
{
  "@timestamp": "2026-09-21T16:11:23.100Z",
  "log.level": "INFO",
  "message": "Started DemoApplication in 1.23 seconds",
  "service.name": "monitoring-java",
  "process.thread.name": "main",
  "log.logger": "com.example.demo.DemoApplication"
}
```
