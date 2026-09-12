echo "Installing K9S..."
# Version fixée pour éviter le rate-limit de l'API GitHub
K9S_VERSION="v0.51.0"

curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o /tmp/k9s.tar.gz
tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s
rm -f /tmp/k9s.tar.gz
