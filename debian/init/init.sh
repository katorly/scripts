#!/bin/bash

clear
echo -e "====== Debian init script - by katorly ======="

while true; do
    read -p "Enter SSH port (1-65535): " SSH_PORT
    if [[ $SSH_PORT -ge 1 && $SSH_PORT -le 65535 ]]; then
        break
    else
        echo "Port must be between 1 and 65535!"
    fi
done
read -p "Enter your username: " SSH_USERNAME
read -p "Enter your public key: " PUBKEY

echo -e "\n\nInstalling packages..."
apt-get update -y && apt-get install -y sudo ufw curl wget vim

echo -e "\n\nAdding user..."
adduser --disabled-password --gecos "" $SSH_USERNAME
echo -e "$SSH_USERNAME:123@@@" | chpasswd
passwd -e $SSH_USERNAME
usermod -aG sudo $SSH_USERNAME

echo -e "\n\nConfiguring SSH..."
grep -q "^#\?Port " /etc/ssh/sshd_config && sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config || echo -e "Port $SSH_PORT" >> /etc/ssh/sshd_config
grep -q "^#\?PubkeyAuthentication " /etc/ssh/sshd_config && sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" /etc/ssh/sshd_config || echo -e "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
grep -q "^#\?PermitRootLogin " /etc/ssh/sshd_config && sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config || echo -e "PermitRootLogin no" >> /etc/ssh/sshd_config
grep -q "^#\?PasswordAuthentication " /etc/ssh/sshd_config && sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config || echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config
grep -q "^ListenStream=" /lib/systemd/system/ssh.socket && sed -i "s/^ListenStream=.*/ListenStream=$SSH_PORT/" /lib/systemd/system/ssh.socket || sed -i "/\[Socket\]/a ListenStream=$SSH_PORT" /lib/systemd/system/ssh.socket
service sshd restart
systemctl daemon-reload
systemctl reload ssh

echo -e "\n\nInstalling Pubkey for user..."
USER_HOME=$(eval echo ~$SSH_USERNAME)
mkdir -p $USER_HOME/.ssh
echo -e "$PUBKEY" > $USER_HOME/.ssh/authorized_keys
chown -R $SSH_USERNAME:$SSH_USERNAME $USER_HOME/.ssh
chmod 600 $USER_HOME/.ssh/authorized_keys

echo -e "\n\nOpening ports..."
ufw default deny
ufw allow OpenSSH
ufw allow SSH
ufw allow VNC
ufw allow $SSH_PORT/tcp
yes | ufw enable
ufw reload

echo -e "\n\nDefault password: 123@@@"
echo -e "============= Done! - by katorly =============\n\n"