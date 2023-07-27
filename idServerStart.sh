#!/usr/bin/env bash
set -e

Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
BYellow='\033[1;33m'
NC='\033[0m'

docker_compose="docker-compose -p identity -f docker-compose.identity.yml --log-level ERROR"

function outputLogo {
echo "

███████ ████████ ██████   █████  ████████  ██████      ██ ██████  
██         ██    ██   ██ ██   ██    ██    ██    ██     ██ ██   ██
███████    ██    ██████  ███████    ██    ██    ██     ██ ██   ██
     ██    ██    ██   ██ ██   ██    ██    ██    ██     ██ ██   ██
███████    ██    ██   ██ ██   ██    ██     ██████      ██ ██████ 

"
}

function help {
  outputLogo
  echo -e "${BYellow}STRATO run script${NC}
Kickstart the STRATO node.

${Yellow}Optional flags:${NC}
The entrypoints are mutually exclusive.
--help|-h       - this help.
--set-password  - set or re-enter the STRATO Provider's in-memory password; use PASSWORD env var to skip interactive input.
--stop          - stop STRATO containers (keeps containers and volumes.)
--start         - start the existing STRATO containers after they were stopped (the opposite to --stop.)
--down          - remove strato containers and leave all volumes intact.
--wipe          - stop and remove STRATO containers and wipe out volumes.
--compose       - fetch the latest stable docker-compose.identity.yml.
--pull          - pull images used in docker-compose.identity.yml.

${Yellow}Environment variables:${NC}
PASSWORD           - STRATO Provider's in-memory password. To be requested interactively if skipped.
HTTP_PORT          - (default: 8090) Port for HTTP traffic listener.
HTTPS_PORT         - (default: 8093) Port for HTTPS traffic listener; only used with ssl=true.
ssl                - (default: false) [true|false] to run the node with SSL/TLS.
sslCertFileType    - (default: pem) [pem|crt] the SSL certificate type and file extension (should be accessible at ./ssl/certs/server.<sslCertFileType> at deploy time.)
INITIAL_OAUTH_DISCOVERY_URL       - (required) OpenID Connect discovery URL for initial OAuth2 provider. Additional ones can be added at run time.
INITIAL_OAUTH_ISSUER              - (required) Issuer value for initial OAuth2 provider.
INITIAL_OAUTH_JWT_USERNAME_CLAIM  - (default: sub) The claim (payload property) of JWT token to use as unique user id within STRATO Provider."
}

function wipe {
  echo -e "${Yellow}Removing Provider containers and wiping out volumes${NC}"
  ${docker_compose} down -vt 0 --remove-orphans
}

function down {
  echo -e "${Yellow}Removing Provider containers${NC}"
  ${docker_compose} down --remove-orphans
}

function stop {
  echo -e "${Yellow}Gently stopping Provider containers${NC}"
  ${docker_compose} stop
}

function start {
  echo -e "${Yellow}Starting the earlier stopped Provider containers${NC}"
  ${docker_compose} start
}

function getCompose {
  echo -e "${Yellow}Downloading the latest stable version of docker-compose.identity.yml...${NC}"
  curl -fLo docker-compose.identity.yml https://github.com/blockapps/strato-getting-started/releases/download/$(curl -s -L https://github.com/blockapps/strato-getting-started/releases/latest | grep -om1 '"/blockapps/strato-getting-started/releases/tag/[^"]*' | grep -oE "[^/]+$")/docker-compose.identity.yml
  echo -e "${Yellow}docker-compose.identity.yml downloaded successfully.${NC}"
}

function pullImages {
  ${docker_compose} pull
}

function setPassword {
    while [ -z $PASSWORD ]; do
      echo
      echo -n Please enter a password:
      read -s PASSWORDA || (printf "\nerror: unable to read password, stdin might be closed\n" &&
                            printf "Set the PASSWORD environment variable in automated environments\n" &&
                            exit 18)
      echo
      echo -n Please re-enter the password:
      read -s PASSWORDB
      if [ "${PASSWORDA}" == "${PASSWORDB}" ]; then
        echo
        PASSWORD=${PASSWORDA}
      else
        echo
        echo -n Passwords did not match. Please try again.
      fi
    done

    PASSWORD_SET_RESPONSE=$(docker exec -i identity_identity-provider_1 curl -s -H "Content-Type: application/json" -d @- localhost:8000/strato/v2.3/password <<< \"$PASSWORD\")
    case ${PASSWORD_SET_RESPONSE} in
      "\"Could not validate password\"" )
        echo -e "${Red}Wrong password provided, please try again.${NC}"
        exit 15
        ;;
      "[]" )
        echo -e "${Green}The password has been set.${NC}"
        ;;
      "\"Password is already set\"" )
        echo -e "${Yellow}The password has been set earlier and the Provider is currently active. No need to re-enter the password.${NC}"
        ;;
    esac
}


if [ ! -f $(pwd)/strato ]; then
    echo -e "${Red}Should be run from within the strato-getting-started directory. Exit.${NC}"
    exit 4
fi

if ! docker ps &> /dev/null
then
    echo -e "${Red}Error: docker is required: https://www.docker.com/ . If you have it installed - you may need to execute as super user${NC}"
    exit 1
fi

if ! docker-compose -v &> /dev/null
then
    echo -e "${Red}Error: docker-compose is required: https://docs.docker.com/compose/install/"
    exit 2
fi

STRATOGS_REQUIRED_VERSION=$(grep strato-getting-started-min-version docker-compose.identity.yml | awk -F":" '{print $NF}')
if [ ${STRATOGS_REQUIRED_VERSION} ]; then
  STRATOGS_CURRENT_VERSION=$(< VERSION)
  if ! awk -v VER=${STRATOGS_CURRENT_VERSION//.} -v REQ_VER=${STRATOGS_REQUIRED_VERSION//.} 'BEGIN {exit (VER < REQ_VER)}'
  then
      echo -e "${Red}The STRATO version from docker-compose.identity.yml is incompatible with this strato-getting-started. Please update to v${STRATOGS_REQUIRED_VERSION}."
      exit 12
  fi
fi

while [ ${#} -gt 0 ]; do
  case "${1}" in
  --help|-h)
    help
    exit 0
    ;;
  --stop)
    stop
    exit 0
    ;;
  --start)
    start
    exit 0
    ;;
  --down)
    down
    exit 0
    ;;
  --wipe)
    wipe
    exit 0
    ;;
  --compose)
    getCompose
    exit 0
    ;;
  --pull)
    pullImages
    exit 0
    ;;
  *)
    echo -e "${Red}Unknown flag ${1} provided, please check --help. Exit.${NC}"
    exit 5
    ;;
  esac
  shift 1
done

outputLogo

if [ "$ssl" = true ] ; then
  http_protocol=https
  main_port=${HTTPS_PORT}
else
  http_protocol=http
  main_port=${HTTP_PORT}
fi
export sslCertFileType=${sslCertFileType:-pem}

if [[ -z ${OAUTH_DISCOVERY_URL} || -z ${OAUTH_CLIENT_ID} || -z ${OAUTH_CLIENT_SECRET} ]] ; then
  echo -e "${Red}OAUTH_DISCOVERY_URL, OAUTH_CLIENT_ID, and OAUTH_CLIENT_SECRET are required to start the STRATO identity server.\nFor additional help see './identity-server --help'${NC}"
  exit 13
fi

echo "" && echo "*** Common Config ***"
echo "HTTP_PORT: $HTTP_PORT"
echo "HTTPS_PORT: $HTTPS_PORT"
echo "ssl: $ssl"
echo "sslCertFileType: $sslCertFileType"
echo "INITIAL_OAUTH_DISCOVERY_URL: ${INITIAL_OAUTH_DISCOVERY_URL}"
echo "INITIAL_OAUTH_ISSUER: ${INITIAL_OAUTH_ISSUER}"
echo "INITIAL_OAUTH_JWT_USERNAME_CLAIM: ${INITIAL_OAUTH_ISSUER:-'using default'}"
echo "PASSWORD: $(if [ -z ${PASSWORD} ]; then echo "not provided (to be set in stdin)"; else echo "provided in env var"; fi)"


if [[ ${HTTP_PORT} == ${HTTPS_PORT} ]]; then
  echo -e "${Red}Can not bind HTTP and HTTPS listeners to same port (${HTTP_PORT})${NC}"
  exit 7
fi

if [ ! -f docker-compose.identity.yml ]
then
  getCompose
else
  echo -e "${BYellow}Using the existing docker-compose.identity.yml (to download the most recent stable version - remove the file and restart the script)${NC}"
fi

# COMPOSE FILE PRE-PROCESSING
function cleanup {
  rm docker-compose-identity-temp.yml
}
trap cleanup EXIT

if [ "$ssl" != true ]; then
  sed -n '/#TAG_REMOVE_WHEN_NO_SSL/!p' docker-compose.identity.yml > docker-compose-identity-temp.yml
else
  if [ ${HTTPS_PORT} != "8093" ]; then
    sed -n '/#TAG_REMOVE_WHEN_SSL_CUSTOM_HTTPS_PORT/!p' docker-compose.identity.yml > docker-compose-identity-temp.yml
  else
    cp docker-compose.identity.yml docker-compose-identity-temp.yml
  fi
fi
# END OF COMPOSE FILE PRE-PROCESSING

${docker_compose} -f docker-compose-identity-temp.yml up -d --remove-orphans
until curl --silent --output /dev/null --fail --insecure --location "${http_protocol}://localhost:${main_port}/ping" ; do sleep 0.5; done

echo -e "\n${Green}STRATO Identity Server has awoken. Check ${http_protocol}://your.hostname:${main_port}${NC}"
