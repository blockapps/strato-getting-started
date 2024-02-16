#!/bin/bash

# Note: NODE_HOST, OAUTH_DISCOVERY_URL, VAULT_URL and STRIPE_PAYMENT_SERVER_URL will be removed from the script for future STRATO versions.

NODE_HOST="<DOMAIN_NAME>" \
  network='mercata-hydrogen' \
  certInfo='{"orgName":"BlockApps","orgUnit":"Mercata","commonName":"<COMMON_NAME>"}' \
  OAUTH_DISCOVERY_URL="https://keycloak.blockapps.net/auth/realms/mercata-testnet2/.well-known/openid-configuration" \
  OAUTH_CLIENT_ID="<CLIENT_ID>" \
  OAUTH_CLIENT_SECRET="<CLIENT_SECRET>" \
  SENDGRID_API_KEY="<SENDGRID_API_KEY>" \
  VAULT_URL="https://vault.blockapps.net:8093" \
  STRIPE_PAYMENT_SERVER_URL="https://payments.mercata-testnet2.blockapps.net" \
  ./strato
