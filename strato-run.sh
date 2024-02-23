#!/bin/bash

# Note: `NODE_HOST` and `ssl` will be removed from the basic run script for future STRATO versions.

NODE_HOST="<DOMAIN_NAME>" \
  network='mercata-hydrogen' \
  certInfo='{"orgName":"BlockApps","orgUnit":"Mercata","commonName":"<COMMON_NAME>"}' \
  OAUTH_CLIENT_ID="<CLIENT_ID>" \
  OAUTH_CLIENT_SECRET="<CLIENT_SECRET>" \
  SENDGRID_API_KEY="<SENDGRID_API_KEY>" \
  ./strato
