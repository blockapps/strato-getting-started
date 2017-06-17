# strato-getting-started

Strato Trials and Getting Started guide
-----------------
[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

*Pre-requisites for the setup*
- This Developer Trial Edition only works on Linux/MacOSX with Docker installed.
- Install Docker on your machine: https://www.docker.com/community-edition
- Install docker-compose on your machine: https://docs.docker.com/compose/install/
- STRATO services need the following ports to be available on the machine (refer docker-compose.yml for details)
```bash
:80 (for NGINX)
:8080 (for API docs)
:5432 (for Postgresql)
:10001 (for Bloc API service)
:6379 (for Redis)
:30303 and :33000 (for Strato)
:3001 (for Postgrest)
:9000 (for Explorer)
:2181 (for Zookeeper)
:9092 (for Kafka)
```

*Steps to setup and run STRATO Developer Edition using Docker on your machine*

1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial

2) Clone this repo using git clone. And `chdir` or `cd` into that folder.

3) Configure docker registry login using the credentials [USER, PASSWORD, REGISTRY] you received via email after your registration for trial: 
```bash
docker login -u <USER> -p <PASSWORD> <REGISTRY> 
```
4) Launch STRATO services:
- Run: 
```bash
chmod +x strato-run.sh 
```
- Then run the script: 
```bash
./strato-run.sh
```
 
5) Check if STRATO services are running (using `docker ps`) & view the Strato Management Dashboard at http://localhost/

![Alt text](SMD.png?raw=true "STRATO Management Dashboard")

- Explore the Bloc and STRATO API docs via the top right link on the Dashboard 

API Docs can also be accessed at these endpoints directly:
```
strato-api: http://localhost/strato-api/eth/v1.2/docs
bloc api: http://localhost/bloc/v2.1/docs
```
Default credentials for UI web pages:
```
username: admin
password: admin
```

6) Refer documentation here to get started with developing a sample app: https://github.com/blockapps/blockapps-ba

7) Reach out to BlockApps team for more info on support and enterprise licensed subscription: http://blockapps.net/learn-more-blockapps-strato-demo/

Stopping STRATO
---------------
*To stop a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)*
```bash
./strato-run.sh -stop 
```

*To stop and wipe out a running instance of STRATO Developer Edition on your machine, run this command (from within the git cloned `getting-started` folder)(you will lose state of any  transactions/data created in the blockchain)*
```bash
./strato-run.sh -wipe 
```
- To force kill all the running STRATO services (docker containers) run this command:
```bash
docker-compose -p silo kill
docker-compose -p silo down -v
```

Debug view
----------

First do 
```bash
sudo apt-get install -y tmux tmuxinator
```

then you can get an overview of all processes using

```bash
tmuxinator start strato
```

License Agreement
-----------------
See [BlockApps’ Developer Edition Terms of Use](http://developers.blockapps.net/trial-license)


*STRATO Architecture*
![Alt text](STRATO-Architecture.png?raw=true "STRATO-Architecture")
