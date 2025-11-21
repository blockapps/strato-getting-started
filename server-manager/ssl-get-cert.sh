#!/bin/bash
set -e

if [[ "$#" -ne 2 && "$#" -ne 3 ]]; then
    echo -e "The script expects 2 required arguments: domain name and email address. For example: ./ssl-get-cert.sh example.com me@example.com.\nOptional arg #3 - custom strato-getting-started path [default: /datadrive/strato-getting-started]"
    exit 101
fi

DOMAIN=$1
EMAIL=$2
STRATOGS_PATH=${3:-"/datadrive/strato-getting-started"}

LOGFILE="$HOME/strato-server-manager.log"
touch $LOGFILE
log_message() {
    local MESSAGE=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') SSL-GET-CERT : $MESSAGE" | tee -a "$LOGFILE"
}

if [ ! -d $STRATOGS_PATH ]; then
  log_message "Expected to have strato-getting-started at $STRATOGS_PATH, but the directory does not exist."
  exit 102
fi

NGINX_CONTAINER_NAME=$(sudo docker ps --format '{{.Names}}' | grep -E 'strato-nginx-1|strato_nginx_1' || true)

# Ignoring the existing certs if they exist
sudo rm -rf /tmp/letsencrypt && [ -d "/etc/letsencrypt" ] && sudo mv /etc/letsencrypt /tmp/

# if nginx container is running - stop it temporarily for certbot execution
[[ -n "$NGINX_CONTAINER_NAME" ]] && sudo docker stop $NGINX_CONTAINER_NAME && log_message "nginx was temporarily stopped" || true
function start_nginx {
  [[ -n "$NGINX_CONTAINER_NAME" ]] && sudo docker start $NGINX_CONTAINER_NAME && log_message "nginx was started back" || true
}
# start the nginx back even if the certbot failed
trap start_nginx EXIT
sudo certbot certonly --standalone --agree-tos --non-interactive --email "${EMAIL}" -d "${DOMAIN}"
log_message "Certbot executed successfully"
start_nginx
trap - EXIT
DOMAIN_LOWERCASED=$(echo $DOMAIN | tr '[:upper:]' '[:lower:]')
sudo cp /etc/letsencrypt/live/${DOMAIN_LOWERCASED}/fullchain.pem /datadrive/strato-getting-started/ssl/certs/server.pem
sudo cp /etc/letsencrypt/live/${DOMAIN_LOWERCASED}/privkey.pem /datadrive/strato-getting-started/ssl/private/server.key

log_message "Cert and key were copied to strato-getting-started directory"

if [ -n "$NGINX_CONTAINER_NAME" ]; then
  sudo docker cp --follow-link /datadrive/strato-getting-started/ssl/certs/server.pem ${NGINX_CONTAINER_NAME}:/etc/ssl/certs/server.pem
  sudo docker cp --follow-link /datadrive/strato-getting-started/ssl/private/server.key ${NGINX_CONTAINER_NAME}:/etc/ssl/private/server.key
  sudo docker exec ${NGINX_CONTAINER_NAME} openresty -s reload
  log_message "Cert and key were updated on the running node."
else
  log_message "No strato-nginx-1 (or strato_nginx_1) container is running. STRATO is not yet started. Skipping the cert update for the running node."
fi
