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

- Start:
  - Get a `docker-compose.allDocker.yml` from release assets at https://github.com/blockapps/strato-getting-started/releases (v15+ only), and save it as `strato-getting-started/docker-compose.yml`
  - Edit the `strato-run.sh`:
    ```
    NODE_HOST='your-domain-here' \
    network='helium' \
    OAUTH_CLIENT_ID='client-id-here' \
    OAUTH_CLIENT_SECRET='client-secret-here' \
    ssl=true \
    ./strato
    ```
    (for mainnet use `network=upquark`)
  - Replace SSL private key and cert with your own in `ssl/`
  - `sudo ./strato-run.sh`

- Wipe:
  ```
  sudo ./strato --wipe
  ```

- Help:
  ```
  ./strato --help
  ```
