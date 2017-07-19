[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

# STRATO Developer Edition - Getting Started guide

### Pre-requisites

**Linux/MacOSX:**
- Install Docker on your machine: https://www.docker.com/community-edition
- Install Docker Compose on your machine: https://docs.docker.com/compose/install/

**Windows:**
- Install Docker Toolbox ("Docker for Windows" is not currently supported): https://www.docker.com/products/docker-toolbox

STRATO services need the following ports to be available on the machine (refer docker-compose.yml for details):

```bash
:80 (for Nginx)
:2181 (for Zookeeper)
:3001 (for Postgrest)
:3002 (for SMD UI)
:5432, :5434 (for Postgresql)
:6379 (for Redis)
:8080 (for API docs)
:9092 (for Kafka)
:10001 (for Bloc API service)
:30303, :30303 UDP, :33000 (for Strato)
```

### Setup

**Steps to setup and run STRATO Developer Edition using Docker on your machine:**

1. Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial
2. Clone [STRATO Getting Started repo](https://github.com/blockapps/strato-getting-started) using ```git clone``` or download and extract .zip archive. And `chdir` or `cd` into that folder.
3. Configure docker registry login using the credentials [USER, PASSWORD, REGISTRY] you received via email after your registration for trial:
    ```bash
    docker login -u <USER> -p <PASSWORD> <REGISTRY>
    ```
4. Launch STRATO services:
    - Run:
        ```bash
        chmod +x strato-run.sh
        ```
    - Then run the script (runs `latest` STRATO version by default):
        ```bash
        ./strato-run.sh
        ```
        or to run `stable` version:
        ```bash
        ./strato-run.sh --stable
        ```
5. Check if STRATO services are running (using `docker ps`) & view the Strato Management Dashboard at http://localhost/

    >Windows users should always use Docker virtual machine IP address instead of `localhost`, in most cases: `192.168.99.100`

    - Explore the Bloc and STRATO API docs via the top right link on the Dashboard (http://localhost)
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
```bash
./strato-run.sh --stop
```

*To stop and wipe out a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)(you will lose state of any  transactions/data created in the blockchain)*
```bash
./strato-run.sh --wipe
```

### Public STRATO instance

*If you can't run your own STRATO instance on your machine, try our public instance (accessible to anyone with the credentials, so don't host Production or Production-like apps/content):*

http://stratodev.blockapps.net/

>User (for Web and API Docs): *admin*

>Password: *W3b@dm!n*

### Debug view

First do:
```bash
sudo apt-get install -y tmux tmuxinator
```

then you can get an overview of all processes using:

```bash
tmuxinator start strato
```

## License Agreement

See [BlockApps’ Developer Edition Terms of Use](http://developers.blockapps.net/trial-license)


## STRATO Architecture

![STRATO-Architecture](STRATO-Architecture.png?raw=true "STRATO-Architecture")
