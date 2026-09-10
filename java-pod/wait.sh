#!/bin/bash

cat << 'EOF' > /tmp/wait.sh
#!/bin/bash
clear
echo "⏳ Initialisation de l'environnement, veuillez patienter..."
while [ ! -f ~/killercoda-training/microservice-1/target/demo-0.0.1-SNAPSHOT.jar ]; do
    sleep 1
done
clear
echo "✅ Environnement prêt ! Vous pouvez commencer le TP."
EOF

chmod +x /tmp/wait.sh
