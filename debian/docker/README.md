## Install Docker
Install Docker and use ufw to manage docker ports.

### Features
- Install Docker
- Allow running Docker without sudo
- Limit Docker's logs to 300MB and 3 files per container
- Use ufw to manage Docker ports

### Usage
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/katorly/scripts/main/debian/docker/install.sh)
```
or
```bash
bash <(wget -qO- https://raw.githubusercontent.com/katorly/scripts/main/debian/docker/install.sh)
```
