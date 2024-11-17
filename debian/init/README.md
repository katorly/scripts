## Init System
Initialize a freshly-installed system.

### Features
- Install sudo, ufw, curl, wget and vim
- Change SSH port
- Create a non-root user with sudo privileges
- Install public key for user
- Disable root login and password authentication

### Usage
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/katorly/scripts/main/debian/init/init.sh)
```
or
```bash
bash <(wget -qO- https://raw.githubusercontent.com/katorly/scripts/main/debian/init/init.sh)
```
Default password is `123@@@`.

After execution, login with your credentials and you will be prompted to change the default password.
