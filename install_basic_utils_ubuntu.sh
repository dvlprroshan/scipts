#!/bin/bash

# Ubuntu 24.04 Development Environment Setup Script
# This script installs common development tools and PHP extensions

set -e  # Exit on error

# Log file
LOG_FILE="/tmp/script_out.log"
exec 3>&1 4>&2
exec 1>>"$LOG_FILE" 2>&1

# Color codes for output (redirected to terminal)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Total steps for progress calculation
TOTAL_STEPS=13
CURRENT_STEP=0

# Function to show progress bar
show_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local FILLED=$((PERCENT / 2))
    local EMPTY=$((50 - FILLED))
    
    printf "\r${BLUE}Progress: [" >&3
    printf "%${FILLED}s" | tr ' ' '█' >&3
    printf "%${EMPTY}s" | tr ' ' '░' >&3
    printf "] %3d%% - %s${NC}" "$PERCENT" "$1" >&3
    
    if [ $CURRENT_STEP -eq $TOTAL_STEPS ]; then
        echo >&3
    fi
}

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start installation
echo -e "${GREEN}Starting Ubuntu 24.04 Development Setup...${NC}" >&3
echo -e "${YELLOW}Logs are being written to: $LOG_FILE${NC}" >&3
echo >&3

log "Starting installation script"

# Configure timezone
show_progress "Configuring timezone (Asia/Kolkata)..."
log "Setting timezone to Asia/Kolkata"
ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq tzdata
dpkg-reconfigure --frontend noninteractive tzdata

# Update system packages
show_progress "Updating package lists..."
log "Updating package lists"
apt-get update -qq

# Install basic dependencies
show_progress "Installing basic dependencies..."
log "Installing basic dependencies"
apt-get install -y -qq \
    curl \
    wget \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    unzip \
    zip

# Install Git
show_progress "Installing Git..."
log "Installing Git"
apt-get install -y -qq git

# Install Vim
show_progress "Installing Vim..."
log "Installing Vim"
apt-get install -y -qq vim

# Install NVM (Node Version Manager)
show_progress "Installing NVM..."
log "Installing NVM"
export NVM_DIR="/usr/local/nvm"
mkdir -p $NVM_DIR
curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | NVM_DIR=$NVM_DIR bash

# Load NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Add NVM to bashrc for all users
echo 'export NVM_DIR="/usr/local/nvm"' >> /etc/bash.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/bash.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /etc/bash.bashrc

# Install Node.js 22
show_progress "Installing Node.js 22..."
log "Installing Node.js 22"
nvm install 22
nvm use 22
nvm alias default 22

# Create symlinks for node and npm
ln -sf $NVM_DIR/versions/node/$(nvm version)/bin/node /usr/local/bin/node
ln -sf $NVM_DIR/versions/node/$(nvm version)/bin/npm /usr/local/bin/npm

# Install pnpm
show_progress "Installing pnpm..."
log "Installing pnpm"
npm install -g pnpm --silent
ln -sf $NVM_DIR/versions/node/$(nvm version)/bin/pnpm /usr/local/bin/pnpm

# Add PHP 8.4 repository
show_progress "Adding PHP 8.4 repository..."
log "Adding PHP 8.4 repository"
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
apt-get update -qq

# Install PHP 8.4 and common extensions
show_progress "Installing PHP 8.4 and extensions..."
log "Installing PHP 8.4 and extensions"
apt-get install -y -qq \
    php8.4 \
    php8.4-cli \
    php8.4-common \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    php8.4-bcmath \
    php8.4-intl \
    php8.4-readline \
    php8.4-opcache \
    php8.4-gd \
    php8.4-pgsql \
    php8.4-mysql \
    php8.4-sqlite3 \
    php8.4-redis \
    php8.4-imagick \
    php8.4-dev \
    php8.4-fpm

# Install Composer
show_progress "Installing Composer..."
log "Installing Composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 2>&1

# Clean up
show_progress "Cleaning up..."
log "Cleaning up"
apt-get autoremove -y -qq
apt-get clean
rm -rf /var/lib/apt/lists/*

# Collect version information
show_progress "Verifying installations..."
log "Collecting version information"

# Log installed versions
log "Installation completed! Installed versions:"
log "Timezone: $(timedatectl show -p Timezone --value)"
log "Git: $(git --version)"
log "Vim: $(vim --version | head -1)"
log "Node.js: $(node --version)"
log "npm: $(npm --version)"
log "pnpm: $(pnpm --version)"
log "PHP: $(php --version | head -1)"
log "Composer: $(composer --version)"
log "PHP Extensions: $(php -m | tr '\n' ', ')"

# Display completion message
echo >&3
echo -e "${GREEN}✓ Installation completed successfully!${NC}" >&3
echo -e "${YELLOW}Check the log file for details: $LOG_FILE${NC}" >&3
echo >&3
echo -e "${BLUE}Installed versions:${NC}" >&3
echo -e "  Timezone: ${GREEN}$(timedatectl show -p Timezone --value)${NC}" >&3
echo -e "  Git:      ${GREEN}$(git --version | cut -d' ' -f3)${NC}" >&3
echo -e "  Node.js:  ${GREEN}$(node --version)${NC}" >&3
echo -e "  npm:      ${GREEN}$(npm --version)${NC}" >&3
echo -e "  pnpm:     ${GREEN}$(pnpm --version)${NC}" >&3
echo -e "  PHP:      ${GREEN}$(php --version | head -1 | cut -d' ' -f2)${NC}" >&3
echo -e "  Composer: ${GREEN}$(composer --version | cut -d' ' -f3)${NC}" >&3
echo >&3
echo -e "${YELLOW}Note: You may need to source ~/.bashrc or restart your shell to use NVM commands${NC}" >&3

# Restore file descriptors
exec 1>&3 2>&4
exec 3>&- 4>&-
