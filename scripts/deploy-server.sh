#!/bin/bash

################################################################################
# Deployment Script for Ubuntu Server
# This script should be placed on your Ubuntu server
################################################################################

set -e  # Exit on any error

# Configuration - Update these variables
PROJECT_NAME="crypto-frontend"
DEPLOY_PATH="/home/work/taogold/tg-fe"
NGINX_CONFIG="/etc/nginx/sites-available/crypto-frontend"
REPO_URL="https://github.com/me-taogold/tg-fe.git"
BRANCH="main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting deployment of ${PROJECT_NAME}${NC}"
echo -e "${GREEN}=====================================${NC}"

# Check if running as root for nginx operations
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Some operations may require sudo privileges${NC}"
fi

# Navigate to deployment directory
cd "$DEPLOY_PATH" || {
    echo -e "${RED}Deployment path not found: $DEPLOY_PATH${NC}"
    exit 1
}

echo -e "${YELLOW}[1/7] Pulling latest changes from Git...${NC}"
git fetch origin
git reset --hard origin/$BRANCH

echo -e "${YELLOW}[2/7] Installing dependencies...${NC}"
npm ci --production=false

echo -e "${YELLOW}[3/7] Loading environment variables...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please create .env file with required variables${NC}"
    exit 1
fi

echo -e "${YELLOW}[4/7] Building application...${NC}"
npm run build

echo -e "${YELLOW}[5/7] Backing up previous build...${NC}"
if [ -d "build.backup" ]; then
    rm -rf build.backup
fi
if [ -d "current" ]; then
    mv current build.backup
fi

echo -e "${YELLOW}[6/7] Deploying new build...${NC}"
if [ -d "current" ]; then
    rm -rf current
fi
mv build current

echo -e "${YELLOW}[7/7] Restarting web server...${NC}"
if command -v nginx &> /dev/null; then
    sudo nginx -t && sudo systemctl reload nginx
    echo -e "${GREEN}Nginx reloaded successfully${NC}"
else
    echo -e "${YELLOW}Nginx not found, skipping reload${NC}"
fi

# Clean up old node_modules if needed (optional)
# npm prune --production

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Deployed at: $(date)"
echo -e "Branch: $BRANCH"
echo -e "Commit: $(git rev-parse --short HEAD)"
