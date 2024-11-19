#!/bin/bash

clear
echo -e "====== Docker install script - by katorly ======="

echo -e "\n\nUninstalling old versions if any..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

echo -e "\n\nInstalling packages..."
sudo apt-get update -y && sudo apt-get install -y sudo ufw ca-certificates curl jq
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo -e "\n\nInstalling Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
# newgrp docker

echo -e "\n\nLimiting Docker logs size and using ufw to manage Docker ports..."
LOG_CONFIG='{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "3"
  },
  "iptables": false
}'
if [ ! -f /etc/docker/daemon.json ]; then
    sudo bash -c "echo '$LOG_CONFIG' > /etc/docker/daemon.json"
else
    echo "$LOG_CONFIG" | sudo jq -s '.[0] + .[1]' - /etc/docker/daemon.json | sudo tee /etc/docker/temp.json > /dev/null && sudo mv /etc/docker/temp.json /etc/docker/daemon.json
fi
sudo sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo sed -i 's/^#\?DOCKER_OPTS=.*/DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 -iptables=false"/' /etc/default/docker
sudo sed -i '/\*filter/i *nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING ! -o docker0 -s 172.17.0.0/16 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.18.0.0/15 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.20.0.0/14 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.24.0.0/13 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.32.0.0/11 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.64.0.0/10 -j MASQUERADE\n-A POSTROUTING ! -o docker0 -s 172.128.0.0/9 -j MASQUERADE\nCOMMIT\n' /etc/ufw/before.rules

echo -e "\n\nPlease reboot as soon as possible to apply changes."
echo -e "============= Done! - by katorly =============\n\n"
newgrp docker # This command will open a new shell so should be put at the end of the script