echo "Waiting for network connectivity..."
until curl -s --connect-timeout 2 https://github.com > /dev/null; do
  sleep 2
done

echo "Installing scenario tools..."
# Version fixée pour éviter le rate-limit de l'API GitHub
K9S_VERSION="v0.51.0"

curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o /tmp/k9s.tar.gz
tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s
rm -f /tmp/k9s.tar.gz

echo "Installing Java..."

# Execution dans un sous-shell isole avec entree fermée
(
  export DEBIAN_FRONTEND=noninteractive
  export NEEDRESTART_MODE=a

  apt-get install -y -qq curl zip unzip </dev/null
)

# 3. Suite du script (SDKMAN & OpenJDK 26)
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 26.0.2+1.1-open < /dev/null

echo "Java installation complete!"

echo "Get microservice code..."
git clone https://github.com/hypercube-software/killercoda-training
cd ~/killercoda-training
rm -fr create-pod install-with-helm java-pod
chmod a+x ~/killercoda-training/microservice-1/mvnw

echo "Compile microservice..."
cd ~/killercoda-training/microservice-1/
./mvnw clean install

echo DONE
