#!/bin/bash

cd /datadrive/strato-getting-started || exit 100

# slick one-liner to get newest images, wipe, and resync
sudo ./strato --compose && sudo ./strato --pull && sudo ./strato --wipe && sudo ./strato-run.sh 
