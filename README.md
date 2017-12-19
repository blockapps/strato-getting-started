[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

# STRATO Developer Edition - Getting Started guide

### Architecture

![STRATO-Architecture]("Firstrough(1).png"?raw=true "STRATO-Architecture")

#### Key components to note
- Bloc API: User/Account Management and Smart-contracts management via API.
- STRATO API: Blockchain API for blocks and transactions.
- Cirrus: Index and search smart-contracts, SQL-like query API for looking up smart-contracts and state changes.
- STRATO Management Dashboard (SMD): Web based UI for your Private Ethereum Blockchain Network using Bloc/STRATO API for User and Contracts management & offering SQL like query interface for smart-contracts.

### Sign-up for trial

To use this guide you will need to have signed up for our Developer Edition Trial, if you have not already done so sign up here: [http://developers.blockapps.net/trial](http://developers.blockapps.net/trial)

### Pre-requisites

**Linux/MacOSX:**

- [Install Docker](https://www.docker.com/community-edition) on your machine
- [Install Docker Compose](https://docs.docker.com/compose/install/) on your machine

- For Mac users: Install `wget` using [Homebrew](https://brew.sh/) (use the steps below):

    - Homebrew:

        ```ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"```

    - wget:

        ```brew install wget --with-libressl```

**Windows:**

- [Install Docker Toolbox](https://www.docker.com/products/docker-toolbox) ("Docker for Windows" is not currently supported)

*[The list of the ports](#ports-used) required to be available on the machine*

### Setup

**Steps to setup and run STRATO Developer Edition using Docker on your machine:**

1. Clone [STRATO Getting Started repo](https://github.com/blockapps/strato-getting-started) using ```git clone``` or download and extract .zip archive. And `chdir` or `cd` into that folder.
2. Configure docker registry login using the credentials [USER, PASSWORD, REGISTRY] you received via email after your registration for trial:
    ```
    docker login -u <USER> -p <PASSWORD> <REGISTRY>
    ```
3. Launch STRATO services:
    - Run:
        ```
        chmod +x strato-run.sh
        ```
    - Then run the script (runs `latest` STRATO version by default):
        ```
        ./strato-run.sh
        ```
        
        >If running on the remote machine, provide the NODE_HOST variable with the machine's external IP address or domain (reachable through the network) when running the STRATO: ```NODE_HOST=example.com ./strato-run.sh```

        >Windows users should always provide the NODE_HOST variable with the docker machine IP address (in most cases it is `192.168.99.100`) when running the STRATO: ```NODE_HOST=192.168.99.100 ./strato-run.sh```

        or to run `stable` version:
        ```
        ./strato-run.sh --stable
        ```
        
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
        bloc api: http://localhost/bloc/v2.1/docs
        ```

6. Refer documentation here to get started with developing a sample app: https://github.com/blockapps/blockapps-ba

7. Reach out to BlockApps team for more info on support and enterprise licensed subscription: http://blockapps.net/learn-more-blockapps-strato-demo/

### Stopping STRATO
*To stop a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)*
```
./strato-run.sh --stop
```

*To stop and wipe out a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)(you will lose state of any  transactions/data created in the blockchain)*
```
./strato-run.sh --wipe
```

### Public STRATO instance

*If you can't run your own STRATO instance on your machine, try our public instance (accessible to anyone with the credentials, so don't host Production or Production-like apps/content):*

http://stratodev.blockapps.net/

### Ports used

STRATO services need the following ports to be available on the machine (refer docker-compose.yml for details):

```
:80, :443 (for Nginx)
:30303, :30303/UDP (for Strato P2P)
```

### Debug view

First do:
```
sudo apt-get install -y tmux tmuxinator
```

then you can get an overview of all processes using:

```
tmuxinator start strato
```

For tmux usage refer to [tmux guide](http://man.openbsd.org/OpenBSD-current/man1/tmux.1).

Consider using the tmux mouse mode plugins for better experience.

<!--MKDOCS_DOC_DIVIDER_MULTINODE-->
## Multinode Network (Public STRATO Testnet)

- *In early alpha, bootnode may go down and blockchain data wiped out during refreshes and upgrades* 
- *Use only for testing* 

You can now run your local STRATO node peering it to the main bootnode and experience a multinode blockchain test network.

Here's the command to start your local node to connect and sync with our bootnode:

```
BOOT_NODE_HOST=52.232.191.102 ./strato-multinode-run.sh --stable
```
- The bootnode is: stratodev.blockapps.net 
- Bootnode Dashboard: http://stratodev.blockapps.net/

## Multinode Network (Local setup - 1 Bootnode and 2 Peers)
*Recommended VM capacity: 4vcpu, 16G*

- *In early alpha, blockchain data wiped out during refreshes and upgrades* 
- *Use only for testing* 

You can now run your local STRATO multi-node test network.
Here's the command to start your local multi-node network:

```
BOOT_NODE_HOST=strato ./strato-multinode-run.sh -local
```
To wipe out and stop the local multinode network (volumes wiped so you'll lose state)
```
./strato-multinode-run.sh -local -wipe
```
Here's a quick screenshot of local multinode network dashboard with 2 peers:
![STRATO-local-multinode](strato-local-multi.png?raw=true "STRATO-Local-Multinode")
<!--MKDOCS_DOC_DIVIDER_MULTINODE_END-->

## License Agreement

See [BlockApps’ Developer Edition Terms of Use](http://developers.blockapps.net/trial-license)

