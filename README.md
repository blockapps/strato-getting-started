[![BlockApps logo](https://docs.blockapps.net/_images/blockapps-logo-horizontal-label.jpg)](http://blockapps.net)

# STRATO Mercata - Getting Started

> A bootstrap script to deploy a STRATO Mercata node

### Prerequisites

- Linux/MacOS
- [Docker](https://docs.docker.com) with Compose V2
- Remote VM/VDS:
  - Static IP
  - Associated domain
  - Inbound ports open: 443/tcp, 30303/tcp, 30303/udp
- STRATO Mercata client credentials (OAuth2 client for node identity)
  - Request the credentials for your domain at support.blockapps.net (Request Client Credentials)

### Usage

- Start:
  - Get a `docker-compose.allDocker.yml` from release assets at https://github.com/blockapps/strato-getting-started/releases (v15+ only), and save it as `strato-getting-started/docker-compose.yml`
  - Edit the `strato-run.sh`:
    ```
    NODE_HOST='your-domain-here' \
    network='helium' \
    OAUTH_CLIENT_ID='client-id-here' \
    OAUTH_CLIENT_SECRET='client-secret-here' \
    ./strato
    ```
    (for mainnet use `network=upquark`)
  - `sudo ./strato-run.sh`

- Wipe:
  ```
  sudo ./strato --wipe
  ```

- Help:
  ```
  ./strato --help
  ```
