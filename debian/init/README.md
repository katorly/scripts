## Init System
Initialize a freshly-installed system.

### Features
- Install basic packages: Install sudo, ufw, curl, wget and vim
- Add non-root user: Create a non-root user with sudo privileges
- Install public key for user
- Forbid root login
- Forbid password login
- Change SSH port
- Configure Pubkey: Install Pubkey authentication for user

### Usage
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/katorly/scripts/main/debian/init/init.sh)
```
or
```bash
bash <(wget -qO- https://raw.githubusercontent.com/katorly/scripts/main/debian/init/init.sh)
```
