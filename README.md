# strato-getting-started

Strato Trials and Getting Started guide
-----------------
[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

*Pre-requisites for the setup*
- Install Docker on your machine: https://www.docker.com/community-edition
- Install docker-compose on your machine: https://docs.docker.com/compose/install/
- STRATO services need the following ports to be available on the machine (refer docker-compose.yml for details)
```bash
:80 (for NGINX)
:5432 (for Postgresql)
:10001 (for Bloc API service)
:6379 (for Redis)
:30303 and :33000 (for Strato)
:3001 (for Postgrest)
:9000 (for Explorer)
:2181 (for Zookeeper)
:9092 (for Kafka)
```

*Steps to setup and run STRATO Developer Trial Edition using Docker on your machine*

1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial

2) Clone this repo using git clone.

3) Configure docker registry access using: docker login -u <> -p <> <registry> (from the registration email)

4) Run: 
```bash
chmod +x strato-run.sh 
```
5) Run the script: 
```bash
./strato-run.sh
```

6) Check if STRATO services are running (using 'docker ps')

7) Refer documentation here to get started with developing a sample app: https://github.com/blockapps/pizza-demo

8) For more details: http://developers.blockapps.net/dashboard

9) Reach out to BlockApps team for more info on support and enterprise licensed subscription: http://blockapps.net/learn-more-blockapps-strato-demo/

*Steps to shutdown a running instance of STRATO Developer Trial Edition on your machine (you will lose state of any  transactions/data created in the blockchain)*
- Run this command (from within the git cloned `getting-started` folder)
```bash
docker-compose down -v 
```
- To force kill all the running STRATO services (docker containers) run this command:
```bash
docker-compose kill
```

License Agreement
-----------------
See [BlockApps’ Developer Trial Edition Terms of Use](http://developers.blockapps.net/trial-license)
