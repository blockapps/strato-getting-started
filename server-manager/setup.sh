#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

LOGFILE="$HOME/strato-server-manager.log"
touch $LOGFILE
log_message() {
    local MESSAGE=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') INSTALL : $MESSAGE" | tee -a "$LOGFILE"
}

# Ask user for mandatory variables
read -p "Enter domain name: " DOMAIN_NAME
read -p "Enter admin email address (for Certbot notifications about SSL cert renewal): " ADMIN_EMAIL
read -p "Enter client ID: " CLIENT_ID
read -p "Enter client secret: " CLIENT_SECRET
read -p "Enter the network name ('upquark' for mainnet, 'helium' for testnet) [upquark]: " NETWORK
NETWORK=${NETWORK:-upquark}

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update package lists
sudo apt update

# Install required packages
sudo apt install -y certbot git htop jq ncdu docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_message "Required software has been successfully installed."

# Create the data directory
sudo mkdir -p /datadrive
sudo chown ${USER}:${USER} /datadrive
sudo chmod 755 /datadrive

# Set up Docker to use the new data directory
sudo mkdir -p /datadrive/docker
sudo mkdir -p /etc/docker
echo '{
  "data-root": "/datadrive/docker"
}' | sudo tee /etc/docker/daemon.json

# If Docker is already installed, move existing data
if [ -d "/var/lib/docker" ]; then
    sudo systemctl stop docker
    sudo rsync -aP /var/lib/docker/ /datadrive/docker
    sudo rm -rf /var/lib/docker
    sudo systemctl start docker
fi

# Verify Docker is running and using the new data root (if installed)
if command -v docker &> /dev/null; then
    sudo docker info | grep "Docker Root Dir"
else
    log_message "ERROR: Docker was not installed successfully. Exiting"
    exit 103
fi

log_message "Successfully moved docker directory to /datadrive/docker"

# Check available space
df -h /datadrive

# Clone and set up STRATO
cd /datadrive || exit 101
rm -rf strato-getting-started
git clone https://github.com/blockapps/strato-getting-started
cd strato-getting-started || exit 102

# Download docker-compose.yml of the latest release version
sudo ./strato --compose

# Pull necessary Docker images
sudo ./strato --pull
log_message "Pulled the latest STRATO Docker images"

# Create the run script
cat <<EOF >strato-run.sh
#!/bin/bash
cd /datadrive/strato-getting-started || exit 100
NODE_HOST="$DOMAIN_NAME" \\
network="$NETWORK" \\
OAUTH_CLIENT_ID="$CLIENT_ID" \\
OAUTH_CLIENT_SECRET="$CLIENT_SECRET" \\
ssl=true \\
./strato
EOF
log_message "Created the strato-run.sh file"

# Create a symbolic link in /usr/local/bin
sudo rm -f /usr/local/bin/strato-run
sudo ln -s /datadrive/strato-getting-started/strato-run.sh /usr/local/bin/strato-run
sudo rm -f /usr/local/bin/strato-update
sudo ln -s /datadrive/strato-getting-started/server-manager/update.sh /usr/local/bin/strato-update
sudo rm -f /usr/local/bin/ssl-get-cert
sudo ln -s /datadrive/strato-getting-started/server-manager/ssl-get-cert.sh /usr/local/bin/ssl-get-cert
log_message "Created symlinks for the scripts"

# Check if ufw is used on the host
if command -v ufw > /dev/null; then
    # Get the status of UFW
    UFW_STATUS=$(sudo ufw status)

    # Check if port 80/tcp is not already allowed
    if ! echo "$UFW_STATUS" | grep -q "80/tcp"; then
        log_message "Port 80/tcp not allowed. Adding rule..."
        sudo ufw allow 80/tcp
        log_message "Port 80/tcp has been allowed."
    else
        log_message "Port 80/tcp is already allowed. Skipping."
    fi
else
    log_message "UFW is not used on the host machine. Adding the firewall rule to allow port 80 directly in iptables..."
    sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
    log_message "Port 80/tcp has been allowed."
    if ! command -v netfilter-persistent > /dev/null; then
      sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
      log_message "Installed iptables-persistent package."
    fi
    sudo netfilter-persistent save
    log_message "Saved iptables rules to persist after reboot."
fi


ssl-get-cert "$DOMAIN_NAME" "$ADMIN_EMAIL"

# Add a cron job to renew the SSL certificate every two months automatically

# Remove the crontab job if it was added previously
(sudo crontab -l | grep "ssl-get-cert" && log_message "Crontab job to renew SSL certificate already existed. Removing it...") && sudo crontab -l | grep -v "ssl-get-cert" | sudo crontab -
log_message "Adding the crontab job to renew the SSL certificate every two months..."
(sudo crontab -l || true 2>/dev/null && echo "0 3 2 */2 * ssl-get-cert \"${DOMAIN_NAME}\" \"${ADMIN_EMAIL}\" | tee -a /datadrive/letsencrypt-renew.log") | sudo crontab -
log_message "Your crontab now:"
sudo crontab -l

FINAL_MESSAGE="Installation complete. Run 'strato-run' from anywhere to start STRATO."
log_message "$FINAL_MESSAGE"
echo -e "\n\033[0;32m$FINAL_MESSAGE\033[0m"
