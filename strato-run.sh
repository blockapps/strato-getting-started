#!/usr/bin/env bash

set -e

registry="registry-aws.blockapps.net:5000"

echo "
    ____  __           __   ___
   / __ )/ /___  _____/ /__/   |  ____  ____  _____
  / __  / / __ \/ ___/ //_/ /| | / __ \/ __ \/ ___/
 / /_/ / / /_/ / /__/ ,< / ___ |/ /_/ / /_/ (__  )
/_____/_/\____/\___/_/|_/_/  |_/ .___/ .___/____/
                              /_/   /_/
"

if grep -q "${registry}" ~/.docker/config.json
then
    genesisBlock=$(< gb.json) \
    lazyBlocks=false \
    miningAlgorithm=SHA \
    apiUrlOverride=http://strato:3000 \
    blockTime=2 \
    minBlockDifficulty=8192 \
    docker-compose up -d
else
    echo "Please login to BlockApps Public Registry first:
1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial;
2) Follow the instructions from the registration email to login to BlockApps Public Registry;
3) Run this script again"
fi