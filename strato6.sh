#!/usr/bin/env bash
set -e

Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
BYellow='\033[1;33m'
NC='\033[0m'

mode=${STRATO_GS_MODE:="0"}
node_type=multi
blockstanbul=${blockstanbul:-false}

docker_compose="docker-compose -p strato --log-level ERROR"

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

${Yellow}Alternative entrypoints:${NC}
The entrypoints are mutually exclusive.
Provide no entrypoint to start STRATO node.
--help|-h     - this help;
--version|-v  - show strato-getting-started script version;
--set-password  - provide the in-memory password after the node was restarted; use PASSWORD env var to skip interactive input;
--stop        - stop STRATO containers (keeps containers and volumes);
--start       - start the existing STRATO containers after they were stopped (the opposite to --stop)
--remove      - DEPRECATED: choose --down or --drop-chains
--down        - remove strato containers and leave all volumes intact
--drop-chains - remove strato containers and chain data volumes; user data volumes are kept
--wipe        - stop and remove STRATO containers and wipe out volumes;
--compose     - fetch the latest stable docker-compose.yml;
--pull        - pull images used in docker-compose.yml;
--get-address - get the address of the running node
--fetch-logs  - fetch all STRATO logs into strato_logs.zip (for more info and options refer to './fetchlogs --help')
--fetch-logs-with-db  - fetch all STRATO logs and database dump into strato_logs.zip (WARNING: database data may be sensitive; for more info and options refer to './fetchlogs --help')

${Yellow}Optional flags for STRATO:${NC}
--single              - run the single PBFT-blockstanbul node
--lazy                - run the the lazy mining node (single);
--blockstanbul|--pbft - run the PBFT-blockstanbul node - equal to env var blockstanbul=true; you will need additional environment variables (either isRootNode, or validators and blockstanbulAdmins/isAdmin)

${Yellow}Environment variables:${NC}
PASSWORD           - node in-memory password for STRATO v4.5+ with OAuth enabled. To be requested interactively if skipped
NODE_HOST          - (default: localhost) the hostname or IP of the machine (used for APIs and Dashboard);
BOOT_NODE_IP       - IP address of the boot node to connect to (required for secondary node to discover other peers), ignored when used with --single flag;
HTTP_PORT          - (default: 80) Port for HTTP traffic listener;
HTTPS_PORT         - (default: 443) Port for HTTPS traffic listener; only used with ssl=true;
generateKey        - (default: true) [true|false] Whether or not to generate this node's key - set this to false if migrating an old node with an existing key
isRootNode         - (default: false) [true|false] Whether or not to make this node the initial PBFT validator and admin
isAdmin            - (default: false) [true|false] Whether or not to make this node its own PBFT admin
blockstanbulAdmins - (default: []) Optional list of PBFT admins who can send votes to this node
validators         - (default: []) List of initial PBFT validators - must contain root node address, if joining a network.
ssl                - (default: false) [true|false] to run the node with SSL/TLS;
sslCertFileType    - (default: crt) [pem|crt] the SSL certificate type and file extension (should be accessible in ./ssl/certs/ while deploying);
authBasic          - (default: false) [true|false] use basic access authentication for dashboard and APIs;
uiPassword         - (default: admin) the basic auth password for 'admin' user, ignored when used with authBasic=false;
EXT_STORAGE_S3_BUCKET             - enables external storage feature; the AWS S3 bucket name to use as the blockchain data external storage;
EXT_STORAGE_S3_ACCESS_KEY_ID      - the access key ID for AWS S3 bucket provided;
EXT_STORAGE_S3_SECRET_ACCESS_KEY  - the secret access key for AWS S3 bucket provided;
OAUTH_ENABLED               - (default: false) [true|false] Enable the OAuth-OpenId functional;
OAUTH_DISCOVERY_URL         - (required if OAUTH_ENABLED=true) OAuth provider's OpenID Connect discovery URL;
OAUTH_CLIENT_ID             - (required if OAUTH_ENABLED=true) Client ID of OAuth provider valid for the future STRATO url (http(s)://<NODE_HOST>:<HTTP_PORT/HTTPS_PORT>);
OAUTH_CLIENT_SECRET         - (required if OAUTH_ENABLED=true) Client Secret for the client ID specified;
OAUTH_JWT_USERNAME_PROPERTY - (default: email) The name of property of JWT access token payload to be used as STRATO user name;
OAUTH_SCOPE                 - (default: 'openid email profile') The openid scopes used in session cookie verification (alter for custom OAUTH_JWT_USERNAME_PROPERTY only, refer to your OAuth provider's documentation)
OAUTH_STRATO42_FALLBACK     - (default: false) - STRATO v4.2 OAuth compatibility mode ('OAUTH_JWT_VALIDATION_' config vars used, no OAuth login feature for UIs);
"
}

function wipe {
  echo -e "${Yellow}Removing STRATO containers and wiping out volumes${NC}"
  ${docker_compose} down -v -t 0 --remove-orphans
}

function remove {
  echo -e "${Red}Remove is no longer supported. Use --down to just remove containers or --drop-chains to also remove chain volumes${NC}"
  exit 17
}


function down {
  echo -e "${Yellow}Removing STRATO containers${NC}"
  ${docker_compose} down --remove-orphans
}

function dropChains {
  set +e
  down
  set -e
  docker volume rm --force strato_blocdata strato_kafkadata strato_redisdata strato_stratodata strato_zookeeperdata
}

function stop {
  echo -e "${Yellow}Gently stopping STRATO containers${NC}"
  ${docker_compose} stop
}

function start {
  echo -e "${Yellow}Starting the earlier stopped STRATO containers${NC}"
  ${docker_compose} start
}

function getCompose {
  echo -e "${Yellow}Downloading the latest stable version of docker-compose.yml${NC}"
  curl -s -L https://github.com/blockapps/strato-getting-started/releases/latest | egrep -o '/blockapps/strato-getting-started/releases/download/.*/docker-compose.yml' | wget --base=http://github.com/ -i - -O docker-compose.yml
}

function pbftVote {
    echo -e "submitting a vote into pbft consensus"
    docker exec strato_strato_1 bash -c "set -x && blockstanbul-vote $*"
}

function pullImages {
  ${docker_compose} pull
}

function keygen {
  if [ ! -f docker-compose.yml ]; then getCompose; fi
  DC_STRATO_IMAGE=$(cat docker-compose.yml | grep "STRATO_IMAGE" | sed -e "s/.*:-//" -e "s/}//")
  docker run --rm --entrypoint=keygen ${STRATO_IMAGE:-$DC_STRATO_IMAGE} --count="$1"
}

function getAddress {
  if [[ -n $(docker ps | grep strato_strato_1) ]]; then
    ADDR_RESP=$(docker exec strato_strato_1 bash -c "curl -s -w \"$%{http_code}\" -X GET http://vault-wrapper:8000/strato/v2.3/key -H \"X-USER-UNIQUE-NAME: nodekey\"" | tr '\n' ' ')
    ADDR_RESP_STATUS=$(cut -d$ -f2 <<< ${ADDR_RESP})
    ADDR_RESP_CONTENT=$(cut -d$ -f1 <<< ${ADDR_RESP})
    case "${ADDR_RESP_STATUS}" in
      400):
        echo -e "${Red}This node does not have its key stored in the vault. You are probably running an older version of STRATO${NC}"
        exit 19
        ;;
      503):
        echo -e "${Red}${ADDR_RESP_CONTENT}${NC}"
        exit 23
        ;;
      200):
        echo "$ADDR_RESP_CONTENT" | awk -F 'address\":\"' '{print $2 FS "."}' | cut -d\" -f1
        ;;
      *):
        echo -e "${Red}Error: Unknown response from vault${NC}"
        exit 24
        ;;
    esac
  else
    echo -e "${Red}STRATO is not running. Start STRATO to get the node's address${NC}"
    exit 20
  fi
}

function fetchLogs {
  if [[ "$1" = withdb ]]; then
    withdb_flag="--db-dump"
  fi
  python fetchlogs ${withdb_flag}
}

function setPassword {
  REQUIRES_PASSWORD=$([[ $(docker exec strato_vault-wrapper_1 curl --write-out %{http_code} --silent --output /dev/null localhost:8000/strato/v2.3/password) == "405" ]] && echo "true" || echo "false")
  if [[ "$REQUIRES_PASSWORD" == "true" ]]; then
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

    PASSWORD_SET_RESPONSE=$(docker exec -i strato_vault-wrapper_1 curl -s -H "Content-Type: application/json" -d @- localhost:8000/strato/v2.3/password <<< \"$PASSWORD\")
    case ${PASSWORD_SET_RESPONSE} in
      "\"Could not validate password\"" )
        echo -e "\033[0;31mWrong password provided, please try again.\033[0m"
        exit 15
        ;;
      "[]" )
        echo -e "\033[0;32mThe password has been set.\033[0m"
        ;;
      "\"Password is already set\"" )
        echo "Password is already set and node is active"
        exit 16
        ;;
    esac
  else
    echo "STRATO version is 4.4.1 or older - skipping global password setting"
  fi
}

if [ ! -f $(pwd)/strato ]; then
    echo -e "${Red}Should be run from within the strato-getting-started directory. Exit.${NC}"
    exit 4
fi

if ! docker ps &> /dev/null
then
    echo -e "${Red}Error: docker is required: https://www.docker.com/ . If you have it installed - you may need to run STRATO with sudo user${NC}"
    exit 1
fi

if ! docker-compose -v &> /dev/null
then
    echo -e "${Red}Error: docker-compose is required: https://docs.docker.com/compose/install/"
    exit 2
fi

STRATOGS_REQUIRED_VERSION=$(grep strato-getting-started-min-version docker-compose.yml | awk -F":" '{print $NF}')
if [ ${STRATOGS_REQUIRED_VERSION} ]; then
  STRATOGS_CURRENT_VERSION=$(< VERSION)
  if ! awk -v VER=${STRATOGS_CURRENT_VERSION//.} -v REQ_VER=${STRATOGS_REQUIRED_VERSION//.} 'BEGIN {exit (VER < REQ_VER)}'
  then
      echo -e "${Red}The STRATO version from docker-compose.yml is incompatible with this strato-getting-started. Please update to v${STRATOGS_REQUIRED_VERSION}."
      exit 12
  fi
fi

if [[ -f docker-compose.release.yml || -f docker-compose.release.multinode.yml ]]
then
  echo -e "${Red}docker-compose.release.yml and docker-compose.release.multinode.yml are deprecated. Please remove or rename to docker-compose.yml. Exit.${NC}"
  exit 5
fi

while [ ${#} -gt 0 ]; do
  case "${1}" in
  --help|-h)
    help
    exit 0
    ;;
  --version|-v)
    echo "$(<VERSION)"
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
  --remove)
    remove
    exit 0
    ;;
  --down)
    down
    exit 0
    ;;
  --drop-chains)
    dropChains
    exit 0
    ;;
  --wipe)
    wipe
    exit 0
    ;;
  --stable)
    echo -e "${Red}--stable flag is deprecated. Exit.${NC}"
    ;;
  -m)
    echo "Mode is set to $2"
    mode="$2"
    shift
    ;;
  --blockstanbul|pbft)
    blockstanbul=true
    ;;
  --single)
    node_type=single
    ;;
  --lazy)
    node_type=lazy
    ;;
  --compose)
    getCompose
    exit 0
    ;;
  --pull)
    pullImages
    exit 0
    ;;
  --keygen=*)
    echo -e "${Red}'--keygen is deprecated. You can still use it, for fun"
    keygen "${1#*=}"
    exit 0
    ;;
  --keygen)
    echo -e "${Red}'--keygen N' syntax is deprecated. Use '--keygen=N' instead. Exit.${NC}"
    exit 1
    ;;
  --fetch-logs)
    fetchLogs
    exit 0
    ;;
  --fetch-logs-with-db)
    fetchLogs "withdb"
    exit 0
    ;;
  --blockstanbul-vote)
    pbftVote "${*:2}"
    exit 0
    ;;
  --set-password)
    setPassword
    exit 0
    ;;
  --get-address)
    getAddress
    exit 0
    ;;
  *)
    echo -e "${Red}Unknown flag ${1} provided, please check --help. Exit.${NC}"
    exit 7
    ;;
  esac
  shift 1
done

outputLogo

echo 'Using STRATO 6 or newer'

export NODE_HOST=${NODE_HOST:-localhost}
export HTTP_PORT=${HTTP_PORT:-80}
export HTTPS_PORT=${HTTPS_PORT:-443}
export ssl=${ssl:-false}
if [ "$ssl" = true ] ; then
  http_protocol=https
  main_port=${HTTPS_PORT}
else
  http_protocol=http;
  main_port=${HTTP_PORT}
fi
export sslCertFileType=${sslCertFileType:-crt}
export NODE_NAME=${NODE_NAME:-$NODE_HOST}
export uiPassword=${uiPassword:-}
if [ -n "$uiPassword" ]; then
  export authBasic=true
else
  export authBasic=${authBasic:-false}
fi
export STRATO_GS_MODE=${mode}
export SMD_MODE=${SMD_MODE:-enterprise}

export isAdmin=${isAdmin:-false}


# BEGIN # Vars bloc for backwards-compatibility with STRATO 4.2 and older
export BLOC_URL=${BLOC_URL:-${http_protocol}://$NODE_HOST/bloc/v2.2}
export BLOC_DOC_URL=${BLOC_DOC_URL:-${http_protocol}://$NODE_HOST/docs/?url=/bloc/v2.2/swagger.json}
export STRATO_URL=${STRATO_URL:-${http_protocol}://$NODE_HOST/strato-api/eth/v1.2}
export STRATO_DOC_URL=${STRATO_DOC_URL:-${http_protocol}://$NODE_HOST/docs/?url=/strato-api/eth/v1.2/swagger.json}
export CIRRUS_URL=${CIRRUS_URL:-${http_protocol}://$NODE_HOST/cirrus/search}
export APEX_URL=${APEX_URL:-${http_protocol}://$NODE_HOST/apex-api}
# ENDOF # Vars bloc for backwards-compatibility with STRATO 4.2 and older

if [ "$SMD_MODE" = "enterprise" ] && [ -n "${EXT_STORAGE_S3_BUCKET}" ]; then
  if [[ -z ${EXT_STORAGE_S3_ACCESS_KEY_ID} || -z ${EXT_STORAGE_S3_SECRET_ACCESS_KEY} ]]; then
    echo -e "${Red}The external storage S3 bucket name is provided but one of the credentials is empty. Expected all or none of [EXT_STORAGE_S3_BUCKET, EXT_STORAGE_S3_ACCESS_KEY_ID, EXT_STORAGE_S3_SECRET_ACCESS_KEY]. Exit.${NC}"
    exit 6
  fi
fi

# Process old OAUTH var names - for backwards-compatibility
if [ "$OAUTH_JWT_VALIDATION_ENABLED" = "true" ]; then
  if [ "$OAUTH_STRATO42_FALLBACK" = "true" ]; then
    if [ -z ${OAUTH_JWT_VALIDATION_DISCOVERY_URL} ]; then
      echo -e "${Red}OAUTH_JWT_VALIDATION_DISCOVERY_URL is required for OAUTH_JWT_VALIDATION_ENABLED mode with OAUTH_STRATO42_FALLBACK=true"
      echo -e "For additional help see './strato --help'${NC}"
      exit 14
    fi
  else
    echo -e "${Red}OAUTH_JWT_VALIDATION_ENABLED and OAUTH_JWT_VALIDATION_DISCOVERY_URL variables are deprecated in STRATO v4.3+"
    echo -e "For compatibility with STRATO v4.2, please use the 'OAUTH_STRATO42_FALLBACK=true' mode"
    echo -e "For additional help see './strato --help'${NC}"
    exit 11
  fi
fi

if [ "$OAUTH_ENABLED" = true ]; then
  if [[ -z ${OAUTH_DISCOVERY_URL} || -z ${OAUTH_CLIENT_ID} || -z ${OAUTH_CLIENT_SECRET} ]] ; then
    echo -e "${Red}OAUTH_DISCOVERY_URL, OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET are required for OAUTH_ENABLED mode"
    echo -e "For additional help see './strato --help'${NC}"
    exit 13
  fi
fi

echo "" && echo "*** Common Config ***"
echo "NODE_HOST: $NODE_HOST"
echo "HTTP_PORT: $HTTP_PORT"
echo "HTTPS_PORT: $HTTPS_PORT"
echo "ssl: $ssl"
echo "sslCertFileType: $sslCertFileType"
echo "NODE_NAME: $NODE_NAME"
echo "BLOC_URL (for STRATO v4.2 backwards-compatibility): $BLOC_URL"
echo "BLOC_DOC_URL (for STRATO v4.2 backwards-compatibility): $BLOC_DOC_URL"
echo "STRATO_URL (for STRATO v4.2 backwards-compatibility): $STRATO_URL"
echo "STRATO_DOC_URL (for STRATO v4.2 backwards-compatibility): $STRATO_DOC_URL"
echo "CIRRUS_URL (for STRATO v4.2 backwards-compatibility): $CIRRUS_URL"
echo "APEX_URL (for STRATO v4.2 backwards-compatibility): $APEX_URL"
echo "authBasic: $authBasic"
echo "uiPassword: $(if [[ -z ${uiPassword} ]]; then if [[ ${authBasic} = true ]]; then echo "not set (using default)"; else echo "not set"; fi; else echo "is set"; fi)"
echo "STRATO_GS_MODE: $STRATO_GS_MODE"
echo "SMD_MODE: $SMD_MODE"
echo "EXT_STORAGE_S3_BUCKET: ${EXT_STORAGE_S3_BUCKET:-not set}"
echo "EXT_STORAGE_S3_ACCESS_KEY_ID: $(if [ -z ${EXT_STORAGE_S3_ACCESS_KEY_ID} ]; then echo "not set"; else echo "is set"; fi)"
echo "EXT_STORAGE_S3_SECRET_ACCESS_KEY: $(if [ -z ${EXT_STORAGE_S3_SECRET_ACCESS_KEY} ]; then echo "not set"; else echo "is set"; fi)"
echo "OAUTH_ENABLED: ${OAUTH_ENABLED:-false}"
echo "OAUTH_DISCOVERY_URL: ${OAUTH_DISCOVERY_URL:-not set}"
echo "OAUTH_CLIENT_ID: $(if [ -z ${OAUTH_CLIENT_ID} ]; then echo "not set"; else echo "is set"; fi)"
echo "OAUTH_CLIENT_SECRET: $(if [ -z ${OAUTH_CLIENT_SECRET} ]; then echo "not set"; else echo "is set"; fi)"
echo "OAUTH_JWT_USERNAME_PROPERTY: ${OAUTH_JWT_USERNAME_PROPERTY:-not set (using default)}"
echo "OAUTH_SCOPE: ${OAUTH_SCOPE:-not set (using default)}"
echo "OAUTH_STRATO42_FALLBACK: ${OAUTH_STRATO42_FALLBACK:-false}"

if [ ${node_type} = lazy ]
then
  echo "" && echo -e "${BYellow}Running single node with lazy mining${NC}"

  if [ ${blockstanbul} = true ]; then
    echo -e "${Red}--lazy is incompatible with blockstanbul. Exit.${NC}"
    exit 10
  fi

  export lazyBlocks=true
  export SINGLE_NODE=true

  echo "*** Lazy node Config ***"
  echo "lazyBlocks: $lazyBlocks"
  echo "SINGLE_MODE: $SINGLE_NODE"

elif [ ${node_type} = single ]
then
  echo "" && echo -e "${BYellow}Running single node with PBFT-blockstanbul${NC}"
  export blockstanbul=true
  export lazyBlocks=false
  export SINGLE_NODE=true
  export generateKey=${generateKey:-true}
  export isAdmin=true
  export isRootNode=true
  
  if [[ $(docker ps -a | grep strato_strato_1) ]]; then
    echo -e "${BYellow}Updating the existing STRATO Single node instance - getting it's blockstanbul variables...${NC}"
    STRATO_ENV_VARS=$(docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' strato_strato_1)
    export blockstanbulAdmins=$(echo "${STRATO_ENV_VARS}" | grep blockstanbulAdmins | awk -F"ulAdmins=" '{print $2}')
    export validators=$(echo "${STRATO_ENV_VARS}" | grep validators | awk -F"alidators=" '{print $2}')
    export blockstanbulPrivateKey=$(echo "${STRATO_ENV_VARS}" | grep blockstanbulPrivateKey | awk -F"ivateKey=" '{print $2}')
    export generateKey=false
    
    if [[ -n "$blockstanbulPrivateKey" ]]; then
      echo -e "\n${Red}blockstanbulPrivateKey has been retrieved - you must migrate this key using migrate-nodekey once STRATO is up.${NC}"
      echo -e "The key:${Green} $blockstanbulPrivateKey${NC}\n"
    fi
  fi

  echo "*** Single-node Config ***"
  echo "blockstanbul: $blockstanbul"
  echo "isAdmin: $isAdmin"
  echo "isRootNode: $isRootNode"
  echo "lazyBlocks: $lazyBlocks"
  echo "SINGLE_MODE: $SINGLE_NODE"

else
  if [ ${blockstanbul} = true ]
  then
    echo "" && echo -e "${BYellow}Running node with PBFT-blockstanbul${NC}"

    if [[ -n "$blockstanbulPrivateKey" ]]; then
      echo -e "${Red}Usage of \"blockstanbulPrivateKey\" is deprecated - please remove it. If you wish to upgrade an existing node, please rerun STRATO with generateKey=false, and insert the old key manually using the migrate-nodekey script.${NC}"
      exit 21
    fi
    if [[ ${generateKey} = false ]]; then
      echo -e "\n${BYellow}WARNING: STRATO was started with generateKey=false. The node will not start until you manually insert a key into the vault using the migrate-nodekey script${NC}"
    fi
 
    if [[ -n "$extraFaucets" ]]; then
      echo -e "\n${BYellow}WARNING: STRATO was started with extraFaucets. This variable is deprecated, unless you are joining an existing network from before STRATO 6.0${NC}"
      export extraFaucets=${extraFaucets}
    fi
   
    export blockstanbul=true
    export validators=${validators}
    export blockstanbulAdmins=${blockstanbulAdmins}
    export isAdmin=${isAdmin:-false}
    export isRootNode=${isRootNode:-false}
    export generateKey=${generateKey:-true}
    export numMinPeers=${numMinPeers:-5}
    echo "validators: $validators"
    echo "blockstanbulAdmins: $blockstanbulAdmins"
    echo "isAdmin: $isAdmin"
    echo "isRootNode: $isRootNode"
    echo "generateKey: $generateKey"
    echo "numMinPeers: $numMinPeers"
  else
    echo "" && echo -e "${BYellow}Running node with Proof-of-Work${NC}"

    export miningAlgorithm="SHA"
    export noMinPeers=true # Legacy 0.3.5 support
    export numMinPeers=${numMinPeers:-5}

    echo "miningAlgorithm: $miningAlgorithm"
    echo "noMinPeers(legacy for v0.3.5-): $noMinPeers"
    echo "numMinPeers: $numMinPeers"
  fi

  export lazyBlocks=false
  echo "lazyBlocks: $lazyBlocks"

  BOOT_NODE_IP=${BOOT_NODE_IP:-${BOOT_NODE_HOST}} # Backwards compatibility for old deprecated BOOT_NODE_HOST var name
  if [ -n "$BOOT_NODE_IP" ]
  then
    export bootnode=${BOOT_NODE_IP}
    echo "bootnode: $bootnode"
    if [ ${blockstanbul} != true ]; then
      export useSyncMode=true # sync before mining
      echo "useSyncMode: $useSyncMode"
    fi
  fi
fi

echo "" && echo "*** Genesis Block ***"
if [[ -e "genesis-block.json" && -z ${genesis+x} ]]
then
  export genesisBlock=$(< genesis-block.json)
fi
if [ -z ${genesisBlock+x} ]
then
  echo "Genesis block is not set (using default)"
else
  echo "Using genesis block from genesis-block.json:"
  echo "${genesisBlock}"
fi

# PARAMETERS VALIDATION
if [ ${HTTP_PORT} = ${HTTPS_PORT} ]; then
  echo -e "${Red}Can not bind HTTP and HTTPS listeners to same port (${HTTP_PORT})${NC}"
  exit 7
fi
# Make sure NODE_HOST contains port if custom port is provided
if [ ${main_port} != "80" ] && [ ${main_port} != "443" ] && [[ ${NODE_HOST} != *":${main_port}" ]]; then
  echo -e "${Red}NODE_HOST should contain the port if custom port is set with HTTP_PORT (for non-ssl) or HTTPS_PORT (for ssl). Expected: NODE_HOST=hostname:${main_port}${NC}"
  exit 8
fi
## END OF PARAMETERS VALIDATION

# enable MixPanel metrics
if [ "$mode" != "1" ] ; then curl --silent --output /dev/null --fail --location http://api.mixpanel.com/track/?data=ewogICAgImV2ZW50IjogInN0cmF0b19nc19pbml0IiwKICAgICJwcm9wZXJ0aWVzIjogewogICAgICAgICJ0b2tlbiI6ICJkYWYxNzFlOTAzMGFiYjNlMzAyZGY5ZDc4YjZiMWFhMCIKICAgIH0KfQ==&ip=1; fi
if [ ! -f docker-compose.yml ]
then
  getCompose
else
  echo -e "${BYellow}Using the existing docker-compose.yml (to download the most recent stable version - remove the file and restart the script)${NC}"
fi

# COMPOSE FILE PRE-PROCESSING
function cleanup {
  rm docker-compose-temp.yml
}
trap cleanup EXIT
if [ "$ssl" != true ]; then
  sed -n '/#TAG_REMOVE_WHEN_NO_SSL/!p' docker-compose.yml > docker-compose-temp.yml
else
  if [ ${HTTPS_PORT} != "443" ]; then
    sed -n '/#TAG_REMOVE_WHEN_SSL_CUSTOM_HTTPS_PORT/!p' docker-compose.yml > docker-compose-temp.yml
  else
    cp docker-compose.yml docker-compose-temp.yml
  fi
fi
# END OF COMPOSE FILE PRE-PROCESSING

${docker_compose} -f docker-compose-temp.yml up -d --remove-orphans

# SET PASSWORD FOR VAULT (EVEN NON-OAUTH NODES NEED THIS, SINCE STRATO-CORE USES VAULT)
setPassword

# WAIT FOR STRATO TO RUN
started=$(date +%s)
timeout=180
hc_container=$(${docker_compose} ps | grep '_nginx_' | awk '{print $1}')
if [ -z "$(docker ps -f name=${hc_container} | grep '(.*)')" ]; then
  # STRATO v4.2 or older - no health status in nginx container, checking vault-wrapper's
  hc_container=$(${docker_compose} ps | grep '_vault-wrapper_' | awk '{print $1}')
fi

printf "Waiting for STRATO to rise and shine"
i=0
while ! [[ -n $(docker ps -q -f name=${hc_container} -f health=healthy) ]];  do
  if [[ $(date +%s) -ge ${started}+${timeout} ]]; then
    echo -e "\n${Red}Node did not start within ${timeout}sec. See 'docker ps' for additional info. Exit.${NC}"
    exit 22
  fi
  i=$((i + 1))
  if [[ $((i % 4)) -eq 0 ]]; then printf '\b\b\b   \b\b\b'; else printf '.'; fi
  sleep 0.3
done
printf "\n"

echo -e "\n${Green}STRATO has awoken. Check ${http_protocol}://${NODE_HOST}${NC}"
# END OF WAIT FOR STRATO TO RUN
