#!/bin/bash

clear
echo -e "====== Swap on script - by katorly ======="

read -p "Enter the size of swap (GB): " SWAP_SIZE
while true; do
    read -p "Enter swappiness you want (0-100): " SWAPPINESS
    if [[ $SWAPPINESS -ge 0 && $SWAPPINESS -le 100 ]]; then
        break
    else
        echo "Swappiness must be between 0 and 100!"
    fi
done

echo -e "\n\nRemoving current swapfile..."
sudo apt-get update -y && sudo apt-get install -y util-linux
sudo swapoff -v /swapfile
sudo rm /swapfile

echo -e "\n\nCreating and applying swapfile..."
sudo fallocate -l ${SWAP_SIZE}G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo bash -c "echo '/swapfile swap swap defaults 0 0' >> /etc/fstab"
sudo bash -c "echo 'vm.swappiness=$SWAPPINESS' >> /etc/sysctl.conf"
sudo sysctl -p

echo -e "\n"
free -m
echo -e "============= Done! - by katorly =============\n\n"