[![BlockApps logo](https://blockapps.net/wp-content/uploads/2019/07/blockapps-logo-super-small.png)](http://blockapps.net)

# STRATO - Getting Started guide

> For more detailed information about the STRATO deployment please refer to [BlockApps Developers' Website](https://developers.blockapps.net)

### STRATO Architecture

![STRATO-Architecture](strato-stack.png?raw=true "STRATO-Architecture")

#### Key components to note
- Bloc API: User/Account Management and Smart-contracts management via API.
- STRATO API: Blockchain API for blocks and transactions.
- Cirrus: Index and search smart-contracts, SQL-like query API for looking up smart-contracts and state changes.
- STRATO Management Dashboard (SMD): Web based UI for your Private Ethereum Blockchain Network using Bloc/STRATO API for User and Contracts management & offering SQL like query interface for smart-contracts.

### Pre-requisites

**Linux/MacOSX:**

- [Install Docker](https://www.docker.com/community-edition) on your machine
- [Install Docker Compose](https://docs.docker.com/compose/install/) on your machine
- Python 2.7 for PBFT network deployment

- For Mac users: Install `wget` using [Homebrew](https://brew.sh/) (use the steps below):

    - Homebrew:

        ```ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"```

    - wget:

        ```brew install wget --with-libressl```

**Windows:**

- [Install Docker Toolbox](https://www.docker.com/products/docker-toolbox) ("Docker for Windows" is not currently supported)

*[The list of the ports](#ports-used) required to be available on the machine*

### Setup

**Steps to setup and run single STRATO node using Docker on your machine:**

1. Clone [STRATO Getting Started repo](https://github.com/blockapps/strato-getting-started) using ```git clone``` or download and extract .zip archive. And `chdir` or `cd` into that folder.
2. Launch STRATO single node:
    ```
    ./strato --single
    ```

    >If running on the remote machine, provide the NODE_HOST variable with the machine's external IP address or domain (reachable through the network) when running the STRATO: ```NODE_HOST=example.com ./strato.sh --single```

    >Windows users should always provide the NODE_HOST variable with the docker machine IP address (in most cases it is `192.168.99.100`) when running the STRATO: ```NODE_HOST=192.168.99.100 ./strato.sh --single```


4. Check if STRATO services are running (using `docker ps`) & view the Strato Management Dashboard at `http://localhost/` (or `http://<remote_node_host>/` when running on remote machine)

    >If `NODE_HOST` is set in step 3, use it's value instead of the `localhost` hereinafter

5. Explore the Bloc and STRATO API docs via the top right link on the Dashboard (http://localhost)
        ![STRATO Management Dashboard](SMD.png?raw=true "STRATO Management Dashboard")

    - Default credentials for UI web pages:
        ```
        username: admin
        password: admin
        ```
    - API Docs can also be accessed at these endpoints directly:
        ```
        strato-api: http://localhost/strato-api/eth/v1.2/docs
        bloc api: http://localhost/bloc/v2.2/docs
        ```

6. Refer documentation here to get started with developing a sample app: https://github.com/blockapps/blockapps-ba

7. Reach out to BlockApps team for more info on support and enterprise licensed subscription: http://blockapps.net/learn-more-blockapps-strato-demo/

### Stopping STRATO
*To stop a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)*
```
./strato --stop
```

*To stop and wipe out a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)(you will lose state of any  transactions/data created in the blockchain)*
```
./strato --wipe
```

### Ports used

STRATO services need the following ports to be available on the machine (refer docker-compose.yml for details):

```
:80, :443 (for Nginx)
:30303, :30303/UDP (for Strato P2P)
```

### Need Docker Access?
You need a valid **STRATO License** in order to access the STRATO docker images. If you are getting `image not accessible` errors (example below) then your license is not valid.

```Error response from daemon: pull access denied for registry-x/y/z, repository does not exist or may require 'docker login': denied: requested access to the resource is denied```

You can **purchase a license [here](https://blockapps.net/strato-pricing/)**. Once requested, we will contact you shortly to configure your license.

## License Agreement

See [BlockApps STRATO end user license agreement](https://developers.blockapps.net/eula.html)
