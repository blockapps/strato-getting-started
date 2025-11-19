#!/bin/bash

sudo \
  NODE_HOST='domain_name_here' \
  network='helium' \
  OAUTH_CLIENT_ID='client_id_here' \
  OAUTH_CLIENT_SECRET='client_secret_here' \
  ssl=true \
  ./strato
