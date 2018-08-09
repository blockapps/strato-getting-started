#!/usr/bin/env bash
set -e

Red='\033[0;31m'
Yellow='\033[0;33m'
BYellow='\033[1;33m'
NC='\033[0m'

mode=${STRATO_GS_MODE:="0"}
registry="registry-aws.blockapps.net:5000"
single=false

function outputLogo {
echo "
    ____  __           __   ___
   / __ )/ /___  _____/ /__/   |  ____  ____  _____
  / __  / / __ \/ ___/ //_/ /| | / __ \/ __ \/ ___/
 / /_/ / / /_/ / /__/ ,< / ___ |/ /_/ / /_/ (__  )
/_____/_/\____/\___/_/|_/_/  |_/ .___/ .___/____/
                              /_/   /_/
"
}

function help {
  outputLogo
  echo -e "${BYellow}STRATO run script${NC}
Kickstart the STRATO node.

${Yellow}Optional flags:${NC}
--help    - this help;
--single  - run the single node with lazy mining;
--stop    - stop and remove STRATO containers, keep volumes;
--wipe    - stop and remove STRATO containers and wipe out volumes;
--compose - fetch the latest stable docker-compose.yml;
--pull    - pull images used in docker-compose.yml;

${Yellow}Environment variables:${NC}
NODE_HOST       - (default: localhost) the hostname or IP of the machine (used for APIs and Dashoboard);
BOOT_NODE_IP    - IP address of the boot node to connect to (required for secondary node to discover other peers), ignored when used with --single flag;
ssl             - (default: false) [true|false] to run the node with SSL/TLS;
sslCertFileType - (default: crt) [pem|crt] the SSL certificate type and file extension (should be accessible in ./ssl/certs/ while deploying);
authBasic       - (default: true) [true|false] use basic access authentication for dashboard and APIs;
uiPassword      - (default: admin) the basic auth password for 'admin' user, ignored when used with authBasic=false;
EXT_STORAGE_S3_BUCKET             - enables external storage feature; the AWS S3 bucket name to use as the blockchain data external storage;
EXT_STORAGE_S3_ACCESS_KEY_ID      - the access key ID for AWS S3 bucket provided;
EXT_STORAGE_S3_SECRET_ACCESS_KEY  - the secret access key for AWS S3 bucket provided;
"
}

function wipe {
  echo "Removing STRATO containers and wiping out volumes"
  docker-compose -f docker-compose.yml -p strato down -v -t 0 --remove-orphans
}

function stop {
  echo "Gently stopping and removing STRATO containers"
  docker-compose -f docker-compose.yml -p strato down --remove-orphans
}

function getCompose {
  echo "Downloading the latest stable version of docker-compose.yml"
  curl -s -L https://github.com/blockapps/strato-getting-started/releases/latest | egrep -o '/blockapps/strato-getting-started/releases/download/.*/docker-compose.yml' | wget --base=http://github.com/ -i - -O docker-compose.yml
}

function pullImages {
  docker-compose pull
}

if [ ! -f $(pwd)/strato.sh ]; then
    echo -e "${Red}Should be run from within the strato-getting-started directory. Exiting.${NC}"
    exit 4
fi

if ! docker ps &> /dev/null
then
    echo 'Error: docker is required to be installed and configured for non-root users: https://www.docker.com/'
    exit 1
fi

if ! docker-compose -v &> /dev/null
then
    echo 'Error: docker-compose is required: https://docs.docker.com/compose/install/'
    exit 2
fi

if [[ -f docker-compose.release.yml || -f docker-compose.release.multinode.yml ]]
then
  echo -e "${Red}docker-compose.release.yml and docker-compose.release.multinode.yml are deprecated. Please remove or rename to docker-compose.yml. Exiting.${NC}"
  exit 5
fi

while [ ${#} -gt 0 ]; do
  case "${1}" in
  --help|-h)
    help
    exit 0
    ;;
  --stop|-stop)
    stop
    exit 0
    ;;
  --wipe|-wipe)
    wipe
    exit 0
    ;;
  --stable|-stable)
    echo -e "${Red}--stable flag is now deprecated and is set by default.${NC}"
    ;;
  -m)
    echo "Mode is set to $2"
    mode="$2"
    shift
    ;;
  --single|-single)
    single=true
    ;;
  --compose|-compose)
    getCompose
    exit 0
    ;;
  --pull|-pull)
    pullImages
    exit 0
    ;;
  *)
    echo "Unknown flag ${1} provided, please check --help"
    exit 7
    ;;
  esac
  shift 1
done

outputLogo

if ! grep -q "${registry}" ~/.docker/config.json
then
  echo "Please login to BlockApps Public Registry first:"
  echo "1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial"
  echo "2) Follow the instructions from the registration email to login to BlockApps Public Registry;"
  echo "3) Run this script again"
  exit 3
fi

export NODE_HOST=${NODE_HOST:-localhost}
export ssl=${ssl:-false}
if [ "$ssl" = true ] ; then export http_protocol=https; else export http_protocol=http; fi
export sslCertFileType=${sslCertFileType:-crt}
export NODE_NAME=${NODE_NAME:-$NODE_HOST}
export BLOC_URL=${BLOC_URL:-${http_protocol}://$NODE_HOST/bloc/v2.2}
export BLOC_DOC_URL=${BLOC_DOC_URL:-${http_protocol}://$NODE_HOST/docs/?url=/bloc/v2.2/swagger.json}
export STRATO_URL=${STRATO_URL:-${http_protocol}://$NODE_HOST/strato-api/eth/v1.2}
export STRATO_DOC_URL=${STRATO_DOC_URL:-${http_protocol}://$NODE_HOST/docs/?url=/strato-api/eth/v1.2/swagger.json}
export CIRRUS_URL=${CIRRUS_URL:-${http_protocol}://$NODE_HOST/cirrus/search}
export APEX_URL=${APEX_URL:-${http_protocol}://$NODE_HOST/apex-api}
export authBasic=${authBasic:-true}
export uiPassword=${uiPassword:-}
export STRATO_GS_MODE=${mode}
export SMD_MODE=${SMD_MODE:-enterprise}

if [ "$SMD_MODE" = "enterprise" ] && [ -n "${EXT_STORAGE_S3_BUCKET}" ]; then
  if [[ -z ${EXT_STORAGE_S3_ACCESS_KEY_ID} || -z ${EXT_STORAGE_S3_SECRET_ACCESS_KEY} ]]; then
    echo -e "${Red}The external storage S3 bucket name is provided but one of the credentials is empty. Expected all or none of [EXT_STORAGE_S3_BUCKET, EXT_STORAGE_S3_ACCESS_KEY_ID, EXT_STORAGE_S3_SECRET_ACCESS_KEY]. Exiting.${NC}"
    exit 6
  else
    export EXT_STORAGE_S3_BUCKET=${EXT_STORAGE_S3_BUCKET}
    export EXT_STORAGE_S3_ACCESS_KEY_ID=${EXT_STORAGE_S3_ACCESS_KEY_ID}
    export EXT_STORAGE_S3_SECRET_ACCESS_KEY=${EXT_STORAGE_S3_SECRET_ACCESS_KEY}
  fi
fi

echo "" && echo "*** Common Config ***"
echo "NODE_HOST: $NODE_HOST"
echo "ssl: $ssl"
echo "sslCertFileType: $sslCertFileType"
echo "NODE_NAME: $NODE_NAME"
echo "BLOC_URL: $BLOC_URL"
echo "BLOC_DOC_URL: $BLOC_DOC_URL"
echo "STRATO_URL: $STRATO_URL"
echo "STRATO_DOC_URL: $STRATO_DOC_URL"
echo "CIRRUS_URL: $CIRRUS_URL"
echo "APEX_URL: $APEX_URL"
echo "authBasic: $authBasic"
echo "uiPassword: $(if [ -z ${uiPassword} ]; then echo "not set (using default)"; else echo "is set"; fi)"
echo "STRATO_GS_MODE: $STRATO_GS_MODE"
echo "SMD_MODE: $SMD_MODE"
echo "EXT_STORAGE_S3_BUCKET: ${EXT_STORAGE_S3_BUCKET:-not set}"
echo "EXT_STORAGE_S3_ACCESS_KEY_ID: $(if [ -z ${EXT_STORAGE_S3_ACCESS_KEY_ID} ]; then echo "not set"; else echo "is set"; fi)"
echo "EXT_STORAGE_S3_SECRET_ACCESS_KEY: $(if [ -z ${EXT_STORAGE_S3_SECRET_ACCESS_KEY} ]; then echo "not set"; else echo "is set"; fi)"

if [ ${single} = true ]
then
  echo "" && echo -e "${BYellow}Running single node with lazy mining${NC}"
  export SINGLE_NODE=true
  echo "*** Single-node Config ***"
  echo "SINGLE_MODE: $SINGLE_NODE"
else
  # Multi-node config
  export miningAlgorithm="SHA"
  export lazyBlocks=false
  export noMinPeers=true # Legacy 0.3.5 support
  export numMinPeers=${numMinPeers:-5}
  echo "" && echo "*** Multi-node Config ***"
  echo "miningAlgorithm: $miningAlgorithm"
  echo "lazyBlocks: $lazyBlocks"
  echo "noMinPeers(legacy for v0.3.5-): $noMinPeers"
  echo "numMinPeers: $numMinPeers"
  BOOT_NODE_IP=${BOOT_NODE_IP:-${BOOT_NODE_HOST}} # Backwards compatibility for old deprecated BOOT_NODE_HOST var name
  if [ -n "$BOOT_NODE_IP" ]
  then
    export bootnode=${BOOT_NODE_IP}
    export useSyncMode=true # sync before mining
    echo "bootnode: $bootnode"
    echo "useSyncMode: $useSyncMode"
  fi
  if [[ -e "genesis-block.json" && -z ${genesis+x} ]]
  then
    export genesisBlock=$(< genesis-block.json)
  fi
fi

echo "" && echo "*** Genesis Block ***"
if [ -z ${genesisBlock+x} ]
then
  echo "Genesis block is not set (using default)"
else
  echo "Using genesis block from genesis-block.json:"
  echo "${genesisBlock}"
fi

# enable MixPanel metrics
if [ "$mode" != "1" ] ; then curl http://api.mixpanel.com/track/?data=ewogICAgImV2ZW50IjogInN0cmF0b19nc19pbml0IiwKICAgICJwcm9wZXJ0aWVzIjogewogICAgICAgICJ0b2tlbiI6ICJkYWYxNzFlOTAzMGFiYjNlMzAyZGY5ZDc4YjZiMWFhMCIKICAgIH0KfQ==&ip=1 ;fi
if [ ! -f docker-compose.yml ]
then
  getCompose
else
  echo -e "${BYellow}Using the existing docker-compose.yml (to download the most recent stable version - remove the file and restart the script)${NC}"
fi
docker-compose -f docker-compose.yml -p strato up -d
exit 0;
