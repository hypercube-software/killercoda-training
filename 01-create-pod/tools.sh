#!/bin/bash
LOGFILE=~/install.log
echo "installing tools" > "$LOGFILE"
echo "Waiting for network connectivity..." >> "$LOGFILE"
until curl -s --connect-timeout 2 https://github.com > /dev/null; do
  sleep 2
done
git clone https://github.com/hypercube-software/killercoda-training >> "$LOGFILE" 2>&1
cd ~/killercoda-training/tools || exit 1
chmod a+x *.sh

./k9s.sh >> "$LOGFILE" 2>&1

touch /tmp/done
