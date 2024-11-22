## Install Cloudflared
Install cloudflared.

### Features
- Install cloudflared
- Register cloudflared as a systemd service

### Usage
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/katorly/scripts/main/debian/cloudflared/install.sh)
```
or
```bash
bash <(wget -qO- https://raw.githubusercontent.com/katorly/scripts/main/debian/cloudflared/install.sh)
```

You'll have to get the token from Cloudflare One (Cloudflare Zero Trust) -> Networks -> Tunnels -> Create a tunnel
