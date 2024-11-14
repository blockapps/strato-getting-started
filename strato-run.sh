#!/bin/bash

NODE_HOST="<DOMAIN_NAME>" \
  OAUTH_CLIENT_ID="<CLIENT_ID>" \
  OAUTH_CLIENT_SECRET="<CLIENT_SECRET>" \
  ssl=${ssl:-false} \
  ./strato
