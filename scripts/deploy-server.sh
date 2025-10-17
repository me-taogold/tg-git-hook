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
git pull

echo -e "${YELLOW}[2/7] Installing dependencies...${NC}"
npm i --production=false

echo -e "${YELLOW}[4/7] Building application...${NC}"
npm run build

# Clean up old node_modules if needed (optional)
# npm prune --production

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Deployed at: $(date)"
echo -e "Branch: $BRANCH"
echo -e "Commit: $(git rev-parse --short HEAD)"
