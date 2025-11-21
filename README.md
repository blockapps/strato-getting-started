[![STRATO Mercata logo](https://www.stratomercata.com/images/stratomercata.com/2025.10.11/strato-mercata-logo.png)](https://stratomercata.com)

# STRATO Mercata - Getting Started

> A bootstrap script to deploy a STRATO Mercata node

### Prerequisites

- Linux/MacOS
- [Docker](https://docs.docker.com) with Compose V2
- Remote VM/VDS:
  - Static IP
  - Associated domain
  - SSL certificate
  - Inbound ports open: 443/tcp, 30303/tcp, 30303/udp
- STRATO Mercata client credentials (OAuth2 client for node identity)
  - Request the credentials for your domain at https://support.blockapps.net (Request Client Credentials)

### Usage

- Start a node:
  - Fetch a `docker-compose.yml` of the latest STRATO Mercata release:
    ```
    sudo ./strato --compose
    ```
  - Edit the `strato-run.sh`:
    ```
    NODE_HOST='your-domain-here' \
    network='helium' \
    OAUTH_CLIENT_ID='client-id-here' \
    OAUTH_CLIENT_SECRET='client-secret-here' \
    ssl=true \
    ./strato
    ```
    - Use `network='helium'` for testnet
    - Use `network='upquark'` for mainnet
  - Replace SSL private key and cert with your own in `ssl/`
  - `sudo ./strato-run.sh`

- Wipe a node:
  ```
  sudo ./strato --wipe
  ```

- For help:
  ```
  ./strato --help
  ```

## Server Manager

For an easy way to bootstrap and manage a STRATO node on a remote server, check out the [Server Manager README](server-manager/README.md)
