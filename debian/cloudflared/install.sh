#!/bin/bash

clear
echo -e "====== Cloudflared install script - by katorly ======="

read -p "Enter your cloudflared tunnel token: " TOKEN

echo -e "\n\nInstalling cloudflared..."
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update -y && sudo apt-get install -y cloudflared

echo -e "\n\nRegistering cloudflared as a systemd service..."
sudo tee /etc/systemd/system/cloudflared.service > /dev/null <<EOF
[Unit]
Description=Cloudflare Zero Trust Tunnel

[Service]
Type=simple
ExecStart=cloudflared tunnel --edge-ip-version auto --protocol http2 --heartbeat-interval 10s run --token $TOKEN
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo -e "============= Done! - by katorly =============\n\n"