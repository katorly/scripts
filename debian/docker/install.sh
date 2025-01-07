#!/bin/bash

clear
echo -e "====== Docker install script - by katorly ======="

DOCKER_SOURCE=https://download.docker.com
LOCAL_IP=$(curl -s ifconfig.me)
IP_LOCATION=$(curl -s "https://ipapi.co/${LOCAL_IP}/country/")
if [ "$IP_LOCATION" == "CN" ]; then
    echo -e "Your machine may be located in China."
    read -p "Would you like to install Docker CE from USTC mirror site? (y|n) " MIRROR_PLEASE
    if [ "$MIRROR_PLEASE" == "y" ]; then
        DOCKER_SOURCE=https://mirrors.ustc.edu.cn/docker-ce
    fi
fi

echo -e "\n\nUninstalling old versions if any..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

echo -e "\n\nInstalling packages..."
sudo apt-get update -y && sudo apt-get install -y sudo ufw ca-certificates curl jq
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL $DOCKER_SOURCE/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_SOURCE/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

echo -e "\n\nInstalling Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
# newgrp docker

echo -e "\n\nLimiting Docker logs size..."
LOG_CONFIG='{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "3"
  }
}'
if [ ! -f /etc/docker/daemon.json ]; then
    sudo bash -c "echo '$LOG_CONFIG' > /etc/docker/daemon.json"
else
    echo "$LOG_CONFIG" | sudo jq -s '.[0] + .[1]' - /etc/docker/daemon.json | sudo tee /etc/docker/temp.json > /dev/null && sudo mv /etc/docker/temp.json /etc/docker/daemon.json
fi

echo -e "\n\nPlease reboot as soon as possible to apply changes."
echo -e "============= Done! - by katorly =============\n\n"
newgrp docker # This command will open a new shell so should be put at the end of the script