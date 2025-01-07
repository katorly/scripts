## Install Docker
Install Docker.

### Features
- Install Docker
- Allow running Docker without sudo
- Limit Docker's logs to 300MB and 3 files per container

### Usage
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/katorly/scripts/main/debian/docker/install.sh)
```
or
```bash
bash <(wget -qO- https://raw.githubusercontent.com/katorly/scripts/main/debian/docker/install.sh)
```

After execution, reboot the system as soon as possible to make the changes to `/etc/docker/daemon.json` take effect.
