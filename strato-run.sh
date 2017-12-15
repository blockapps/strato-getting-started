#!/usr/bin/env bash

# Optional arguments:
# `--stop` - stop STRATO containers
# `--wipe` - stop STRATO containers and wipe out volumes
# `--stable` - run stable STRATO version (latest is by default)

set -e

registry="registry-aws.blockapps.net:5000"

function wipe {
    echo "Stopping STRATO containers and wiping out volumes"
    docker-compose -f docker-compose.latest.yml -p strato kill 2> /dev/null || docker-compose -f docker-compose.release.yml -p strato kill
    docker-compose -f docker-compose.latest.yml -p strato down -v 2> /dev/null || docker-compose -f docker-compose.release.yml -p strato down -v
}

function stop {
    echo "Stopping STRATO containers"
    docker-compose -f docker-compose.latest.yml -p strato kill 2> /dev/null || docker-compose -f docker-compose.release.yml -p strato kill
    docker-compose -f docker-compose.latest.yml -p strato down 2> /dev/null || docker-compose -f docker-compose.release.yml -p strato down
}

mode=${STRATO_GS_MODE:="0"}
stable=false

while [ ${#} -gt 0 ]; do
  case "${1}" in
  --stop|-stop)
    stop
    exit 0
    ;;
  --wipe|-wipe)
    wipe
    exit 0
    ;;
  --stable|-stable)
    echo "Deploying the stable version"
    stable=true
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
    export authBasic=${authBasic:-true}
    export uiPassword=${uiPassword:-}
    export STRATO_GS_MODE=${mode}
    export SINGLE_NODE=true
    if [ "$mode" != "1" ] ; then curl http://api.mixpanel.com/track/?data=ewogICAgImV2ZW50IjogInN0cmF0b19nc19pbml0IiwKICAgICJwcm9wZXJ0aWVzIjogewogICAgICAgICJ0b2tlbiI6ICJkYWYxNzFlOTAzMGFiYjNlMzAyZGY5ZDc4YjZiMWFhMCIKICAgIH0KfQ==&ip=1 ;fi
    if [ "$stable" = true ]
    then
      if [ ! -f docker-compose.release.yml ]
      then
        echo "Getting stable release docker-compose.release.yml from latest release tag: https://github.com/blockapps/strato-getting-started/releases/latest"
        curl -s -L https://github.com/blockapps/strato-getting-started/releases/latest | egrep -o '/blockapps/strato-getting-started/releases/download/build-[0-9]*/docker-compose.release.yml' | wget --base=http://github.com/ -i - -O docker-compose.release.yml
      else
        echo "docker-compose.release.yml exists - using it for current --stable run"
      fi
      docker-compose -f docker-compose.release.yml -p strato up -d
    else
      curl -L https://github.com/blockapps/strato-getting-started/releases/download/build-latest/docker-compose.latest.yml -O
      docker-compose -f docker-compose.latest.yml pull && docker-compose -f docker-compose.latest.yml -p strato up -d
    fi
else
    echo "Please login to BlockApps Public Registry first:
1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial
2) Follow the instructions from the registration email to login to BlockApps Public Registry;
3) Run this script again"
    exit 3
fi
