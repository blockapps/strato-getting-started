[<img src="https://strato.nexus/images/strato.nexus/2025.10.11/strato-logo.png">](https://strato.nexus)

# STRATO Node Provisioning

This guide will help you set up a STRATO Node on a remote virtual machine.

### Prerequisites:
- VM with at least 2 vCPU (1 core/2 threads), 8GB RAM, 80GB SSD
- Ubuntu LTS (24.04 recommended)
- A domain name pointing to your server's IP address
- Client ID/Secret from BlockApps (request for your domain name at https://support.blockapps.net)
- (**Optional, advanced**): separate data volume mounted to '/datadrive'
- Firewall Settings:
  - Inbound:
    - 22/tcp - SSH access
    - 80/tcp (0.0.0.0/0) - HTTP IPv4 for CertBot (Let's Encrypt SSL certificates)
    - 443/tcp (::/0) - HTTPS IPv6
    - 443/tcp (0.0.0.0/0) - HTTPS IPv4
    - 30303/tcp (0.0.0.0/0) - STRATO P2P
    - 30303/udp (0.0.0.0/0) - STRATO P2P
  - Outbound: 
    - Allow all (default)

## STRATO Setup
1. Review the installation script `setup.sh` in this repo for security, then SSH into your server and run:
    ```shell
    bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/setup.sh)
    ```
    You will be prompted to enter your node's domain name, admin email address, CLIENT_ID, CLIENT_SECRET, and NETWORK (optional)
2. Launch your node: 
   ```shell
   sudo strato-run
   ``` 

## STRATO Update

To update your node to the latest release, run:
```shell
sudo bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/update.sh)
```
or simply:
```shell
sudo strato-update
```

## SSL Certificate Update

**No manual steps are required.** The SSL certificate is updated automatically every 2 months via a cron job. 

If you need to manually renew the certificate, run:
```shell
bash <(curl -sSL https://raw.githubusercontent.com/blockapps/strato-getting-started/master/server-manager/ssl-get-cert.sh) YOUR_DOMAIN YOUR_EMAIL
```
or simply:
```shell
ssl-get-cert YOUR_DOMAIN YOUR_EMAIL
```
