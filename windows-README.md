## Run locally with Docker for Windows

### Prerequisites:

- Docker for Windows (version 17.03.1+): https://docs.docker.com/docker-for-windows/
- Docker-compose: https://docs.docker.com/compose/install/

### Run steps:

1. Clone STRATO Getting Started repo or download repo .zip file and unpack.
2. Download [docker-compose.latest.yml](https://github.com/blockapps/strato-getting-started/releases/download/build-latest/docker-compose.latest.yml) to the same folder (which should also contain `windows-strato-run.bat` file)
3. Run CMD (Command Prompt), navigate to the folder and execute `.\windows-strato-run.bat`

Check if no errors occured and `docker ps` shows the docker containers up and running.

## Public STRATO instance

*If you can't run your own STRATO instance on your machine, try our public instance (accessible to anyone with the credentials, so don't host Production or Production-like apps/content)*

http://stratodev.blockapps.net/
- Web and API Docs user: admin
- password: W3b@dm!n
