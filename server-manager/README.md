[<img src="https://www.stratomercata.com/images/stratomercata.com/2025.10.11/strato-mercata-logo.png">](https://stratomercata.com/)

# STRATO Node Provisioning

### So you want to kickstart a STRATO Node on a remote virtual machine?

Prerequisites:
- A server with a minimum of 2 vCPU (1 core/2 threads), 8GB RAM, 80GB SSD
- Ubuntu LTS version (24.04 is recommended)
- A domain name pointing to your server's IP
- CLIENT_ID and CLIENT_SECRET provided by the BlockApps team (request for your domain at support.blockapps.net).
- Optional (advanced): separate data volume mounted to /datadrive

Steps:
1. Review the installation script `install.sh` in this git repo for security, then ssh into server and run:
    ```shell
    bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/setup.sh)
    ```
    You will be prompted to enter your node's `*domain name*`, `*admin email address*`, `*CLIENT_ID*`, `*CLIENT_SECRET*`, `*NETWORK*` (optional)
2. Launch your node: 
   ```shell
   sudo strato-run
   ``` 

### Firewall Recommendations

Ensure the following ports are open in your firewall:

- 22/tcp - SSH access
- 80/tcp (0.0.0.0/0) - HTTP IPv4 for CertBot (Let's Encrypt SSL certificates)
- 443/tcp (::/0) - HTTPS IPv6
- 443/tcp (0.0.0.0/0) - HTTPS IPv4
- 30303/tcp (0.0.0.0/0) - STRATO P2P
- 30303/udp (0.0.0.0/0) - STRATO P2P

### STRATO Update

To update your node to the latest release, run:
```shell
sudo bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/update.sh)
```
or simply:
```shell
sudo strato-update
```

### SSL Certificate Update

The SSL certificate is updated automatically every 2 months with a crontab job. 

In case you need to initiate the certificate renewal process manually, execute:
```shell
bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/ssl-get-cert.sh) YOUR_DOMAIN YOUR_EMAIL
```
or simply:
```shell
ssl-get-cert YOUR_DOMAIN YOUR_EMAIL
```
