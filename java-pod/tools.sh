echo "Installing scenario tools..."
curl -sS https://webinstall.dev/k9s | bash > /dev/null
source ~/.config/envman/PATH.env

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
rm -fr create-pod install-with-helm java-pod
chmod a+x ~/killercoda-training/microservice-1/mvnw

echo "Compile microservice..."
./mvnw clean install

echo DONE