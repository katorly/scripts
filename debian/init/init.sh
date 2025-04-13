#!/bin/bash

install_packages() {
    echo -e "\n\nInstalling basic packages..."
    apt-get update -y && apt-get install -y sudo ufw curl wget vim

    echo -e "\n\nOpening ports..."
    ufw default deny
    ufw allow OpenSSH
    ufw allow SSH
    ufw allow VNC
    yes | ufw enable
    ufw reload

    echo -e "\n\nInstall basic packages successfully!"
}

add_non_root_user() {
    clear
    read -p "Enter your username: " SSH_USERNAME
    read -s -p "Enter your password: " SSH_PASSWORD

    echo -e "\n\nAdding user $SSH_USERNAME..."

    adduser --disabled-password --gecos "" $SSH_USERNAME
    echo -e "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    passwd -e $SSH_USERNAME
    usermod -aG sudo $SSH_USERNAME

    echo -e "\n\nUser $SSH_USERNAME added!"
}

forbid_root_login() {
    clear
    echo -e "\n\nForbidding root login..."

    grep -q "^#\?PermitRootLogin " /etc/ssh/sshd_config && sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config || echo -e "PermitRootLogin no" >> /etc/ssh/sshd_config
    service sshd restart

    echo -e "\n\nForbid root login successfully!"
}

configure_pubkey() {
    clear
    read -p "Enter your username: " SSH_USERNAME
    read -p "Enter your public key: " PUBKEY

    echo -e "\n\nConfiguring Pubkey for user..."

    if ! id "$SSH_USERNAME" &>/dev/null; then
        echo "Error: User $SSH_USERNAME does not exist!"
        return 1
    fi

    USER_HOME=$(eval echo ~$SSH_USERNAME)
    mkdir -p $USER_HOME/.ssh
    echo -e "$PUBKEY" > $USER_HOME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME $USER_HOME/.ssh
    chmod 600 $USER_HOME/.ssh/authorized_keys

    grep -q "^#\?PubkeyAuthentication " /etc/ssh/sshd_config && sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" /etc/ssh/sshd_config || echo -e "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    service sshd restart

    echo -e "\n\nConfigure Pubkey successfully!"
}

forbid_password_login() {
    clear
    echo -e "\n\nForbidding password login..."

    grep -q "^#\?PasswordAuthentication " /etc/ssh/sshd_config && sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config || echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config
    service sshd restart

    echo -e "\n\nForbid password login successfully!"
}

change_ssh_port() {
    clear
    while true; do
        read -p "Enter SSH port (1-65535): " SSH_PORT
        if [[ $SSH_PORT -ge 1 && $SSH_PORT -le 65535 ]]; then
            break
        else
            echo "Port must be between 1 and 65535!"
        fi
    done

    echo -e "\n\nChanging SSH port..."

    grep -q "^#\?Port " /etc/ssh/sshd_config && sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config || echo -e "Port $SSH_PORT" >> /etc/ssh/sshd_config
    grep -q "^ListenStream=" /lib/systemd/system/ssh.socket && sed -i "s/^ListenStream=.*/ListenStream=$SSH_PORT/" /lib/systemd/system/ssh.socket || sed -i "/\[Socket\]/a ListenStream=$SSH_PORT" /lib/systemd/system/ssh.socket
    service sshd restart
    systemctl daemon-reload
    systemctl reload ssh

    ufw allow $SSH_PORT/tcp
    ufw reload

    echo -e "\n\nChange SSH port successfully!"
}

enable_swap() {
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

    echo -e "\n\nEnable swap successfully!"
}

show_menu() {
    echo -e "====== Debian init script - by katorly ======="
    echo -e "1. Install basic packages"
    echo -e "2. Add non-root user"
    echo -e "3. Forbid root login"
    echo -e "4. Configure Pubkey"
    echo -e "5. Forbid password login"
    echo -e "6. Change SSH port"
    echo -e "7. Enable swap"
    echo -e "0. Exit"
    echo -e "=============================================="
}

while true; do
    clear
    show_menu
    echo
    read -p "Please select an option: " option
    case $option in
        1) install_packages;;
        2) add_non_root_user;;
        3) forbid_root_login;;
        4) configure_pubkey;;
        5) forbid_password_login;;
        6) change_ssh_port;;
        7) enable_swap;;
        0) 
            echo -e "\nThanks for using this script!"
            exit 0
            ;;
        *) echo "Invalid option!";;
    esac

    read -p "Press Enter to continue..."
done