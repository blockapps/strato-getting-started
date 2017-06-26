::Simple script to run STRATO on Windows
:: Requirements:
:: 1) Docker for Windows
:: 2) Docker-compose tool
:: 3) docker-compose.latest.yml in current folder (see windows-README.md for more info)

set NODE_NAME=localhost
set BLOC_URL=http://localhost/bloc/v2.1
set BLOC_DOC_URL=http://localhost/docs/?url=/bloc/v2.1/swagger.json
set STRATO_URL=http://localhost/strato-api/eth/v1.2
set STRATO_DOC_URL=http://localhost/docs/?url=/strato-api/eth/v1.2/swagger.json
set cirrusurl=nginx/cirrus
set stratoHost=nginx
set ssl=false
docker-compose -f docker-compose.latest.yml up -d