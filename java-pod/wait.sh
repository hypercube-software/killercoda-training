#!/bin/bash

cat << 'EOF' > /tmp/wait.sh
#!/bin/bash
clear
echo "⏳ Initialisation de l'environnement (JDK, K9S, compilation maven etc..), veuillez patienter..."

# Enregistrement du temps de départ
START_TIME=$SECONDS

while [ ! -f ~/killercoda-training/microservice-1/target/demo-0.0.1-SNAPSHOT.jar ]; do
    sleep 1
done

# Calcul de la durée écoulée
DURATION=$((SECONDS - START_TIME))

# Conversion en minutes et secondes
MINUTES=$((DURATION / 60))
SECONDS_LEFT=$((DURATION % 60))

# Formatage MM:SS avec rajout du zéro initial si < 10
ELAPSED=$(printf "%02d:%02d" $MINUTES $SECONDS_LEFT)

clear
echo "✅ Environnement prêt ! Vous pouvez commencer le TP."
echo "⏱️  Temps d'initialisation : ${ELAPSED} (mm:ss)"
EOF

chmod +x /tmp/wait.sh
/tmp/wait.sh