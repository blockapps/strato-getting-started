#!/usr/bin/env bash

# Optional arguments:
# `--stop` - stop STRATO containers
# `--wipe` - stop STRATO containers and wipe out volumes
# `--local` - Run local multinode setup with 3 nodes (1 bootnode and 2 peers) 

set -e

registry="registry-aws.blockapps.net:5000"

RED='\033[0;31m'
NC='\033[0m'

function wipe {
    echo "Stopping STRATO containers"
    if [ "$localMulti" = true ]
    then 
     docker-compose -f docker-compose.localmultinode.yml -p strato kill
     docker-compose -f docker-compose.localmultinode.yml -p strato down -v
    else 
     docker-compose -f docker-compose.release.multinode.yml -p strato kill
     docker-compose -f docker-compose.release.multinode.yml -p strato down -v
    fi
}

function stop {
    echo "Stopping STRATO containers"
    if [ "$localMulti" = true ]
    then
     docker-compose -f docker-compose.localmultinode.yml -p strato kill
     docker-compose -f docker-compose.localmultinode.yml -p strato down 
    else
     docker-compose -f docker-compose.release.multinode.yml -p strato kill
     docker-compose -f docker-compose.release.multinode.yml -p strato down
    fi
}

mode=${STRATO_GS_MODE:="0"}
stable=false
localMulti=false

while [ ${#} -gt 0 ]; do
  case "${1}" in
  --stop|-stop)
    echo "Stopping STRATO containers"
    stop
    exit 0
    ;;
  --wipe|-wipe)
    echo "Stopping STRATO containers and wiping out volumes"
    wipe
    exit 0
    ;;
  --stable|-stable)
    echo "Deploying the stable version"
    stable=true
    ;;
  --local|-local)
    echo "Deploying multinode local on this machine"
    localMulti=true
    ;;
  -m)
    echo "Mode is set to $2"
    mode="$2"
    shift
    ;;
  esac

  shift 1
done

echo "
    ____  __           __   ___
   / __ )/ /___  _____/ /__/   |  ____  ____  _____
  / __  / / __ \/ ___/ //_/ /| | / __ \/ __ \/ ___/
 / /_/ / / /_/ / /__/ ,< / ___ |/ /_/ / /_/ (__  )
/_____/_/\____/\___/_/|_/_/  |_/ .___/ .___/____/
                              /_/   /_/
"

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

if grep -q "${registry}" ~/.docker/config.json
then
    export NODE_HOST=${NODE_HOST:-localhost}
    export NODE_NAME=${NODE_NAME:-$NODE_HOST}
    export BLOC_URL=${BLOC_URL:-http://$NODE_HOST/bloc/v2.2}
    export BLOC_DOC_URL=${BLOC_DOC_URL:-http://$NODE_HOST/docs/?url=/bloc/v2.2/swagger.json}
    export STRATO_URL=${STRATO_URL:-http://$NODE_HOST/strato-api/eth/v1.2}
    export STRATO_DOC_URL=${STRATO_DOC_URL:-http://$NODE_HOST/docs/?url=/strato-api/eth/v1.2/swagger.json}
    export CIRRUS_URL=${CIRRUS_URL:-http://$NODE_HOST/cirrus/search}
    export APEX_URL=${APEX_URL:-http://$NODE_HOST/apex-api}
    export cirrusurl=nginx/cirrus
    export stratoHost=nginx
    export ssl=false
    export STRATO_GS_MODE=${mode}
    export miningAlgorithm="SHA"
    export lazyBlocks=false
    export noMinPeers=true # Legacy 0.3.5 support
    export numMinPeers=${numMinPeers:-5}

    echo "--------------------------------"
    echo " Common Config"
    echo "--------------------------------"
    echo "NODE NAME: $NODE_NAME"
    echo "BLOC_URL: $BLOC_URL"
    echo "BLOC_DOC_URL: $BLOC_DOC_URL"
    echo "STRATO_URL: $STRATO_URL"
    echo "STRATO_DOC_URL: $STRATO_DOC_URL"
    echo "cirrusurl: $cirrusurl"
    echo "stratoHost: $stratoHost"

    # multinode peer configuration
    if [ -n "$BOOT_NODE_HOST" ]
    then
      export bootnode=$BOOT_NODE_HOST
      # sync before mining
      export useSyncMode=true
      echo "--------------------------------"
      echo " Multinode Config"
      echo "--------------------------------"
      echo "bootnode: $bootnode"
      echo "syncMode: $syncMode"
    fi

    # multinode peer configuration
    if [ -e "gb.multinode.json" ]
    then
      export genesisBlock=$(< gb.multinode.json)
      echo "--------------------------------"
      echo " Genesis Block"
      echo "--------------------------------"
      echo "genesisBlock: $genesisBlock"
    fi

    # enable MixPanel metrics
    if [ "$mode" != "1" ] ; then curl http://api.mixpanel.com/track/?data=ewogICAgImV2ZW50IjogInN0cmF0b19nc19pbml0IiwKICAgICJwcm9wZXJ0aWVzIjogewogICAgICAgICJ0b2tlbiI6ICJkYWYxNzFlOTAzMGFiYjNlMzAyZGY5ZDc4YjZiMWFhMCIKICAgIH0KfQ==&ip=1 ;fi

    if [ "$localMulti" = true ]
    then
     docker-compose -f docker-compose.localmultinode.yml -p strato up -d  
     exit 0;
    fi

    if [ "$stable" = true ]
    then
      if [ ! -f docker-compose.release.multinode.yml ]
      then
        echo "Getting stable release docker-compose.release.yml from latest release tag"
        curl -s -L https://github.com/blockapps/strato-getting-started/releases/latest | egrep -o '/blockapps/strato-getting-started/releases/download/build-[0-9]*/docker-compose.release.yml' | wget --base=http://github.com/ -i - -O docker-compose.release.multinode.yml
      fi
      docker-compose -f docker-compose.release.multinode.yml -p strato up -d
      exit 0;
    else
      echo -e "${RED}Multinode can only be ran with --stable flag. Exiting the script ${NC}"
      exit 4
    fi

else
    echo "Please login to BlockApps Public Registry first:
1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial
2) Follow the instructions from the registration email to login to BlockApps Public Registry;
3) Run this script again"
    exit 3
fi
