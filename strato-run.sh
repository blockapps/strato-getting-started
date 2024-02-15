#!/bin/bash

NODE_HOST="localhost" \
  OAUTH_DISCOVERY_URL="OAUTH_DISCOVER_URL_PLACEHOLDER" \
  OAUTH_CLIENT_ID="OAUTH_CLIENT_ID_PLACEHOLDER" \
  OAUTH_CLIENT_SECRET="OAUTH_CLIENT_SECRET_PLACEHOLDER" \
  SENDGRID_API_KEY="SENDGRID_API_KEY_PLACEHOLDER" \
  VAULT_URL="https://vault.blockapps.net:8093" \
  network='mercata-hydrogen' \
  STRIPE_PAYMENT_SERVER_URL="https://payments.mercata-testnet2.blockapps.net" \
  ./strato
