#!/bin/bash
set -e

echo "Installing OpenJDK 26..."

mkdir -p /usr/local/java/jdk

echo "Downloading OpenJDK..."
curl -sLf --retry 3 --retry-delay 2 \
  "https://api.adoptium.net/v3/binary/latest/26/ga/linux/x64/jdk/hotspot/normal/eclipse" \
  -o /tmp/openjdk.tar.gz

if ! tar -tzf /tmp/openjdk.tar.gz >/dev/null 2>&1; then
  echo "ERREUR : Le fichier téléchargé est corrompu ou invalide !"
  rm -f /tmp/openjdk.tar.gz
  exit 1
fi

echo "Extracting OpenJDK..."
tar -xzf /tmp/openjdk.tar.gz -C /usr/local/java/jdk --strip-components=1
rm -f /tmp/openjdk.tar.gz

ln -sf /usr/local/java/jdk/bin/* /usr/local/bin/

export JAVA_HOME=/usr/local/java/jdk

echo "Java installation complete!"
java -version
