#!/bin/bash

################################################################################
# Deployment Script
# Pulls latest code from Git and builds the application
################################################################################

set -e  # Exit on any error

# Configuration - Update these variables
PROJECT_NAME="crypto-frontend"
DEPLOY_PATH="/home/work/taogold/tg-fe"
BRANCH="main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting deployment of ${PROJECT_NAME}${NC}"
echo -e "${GREEN}=====================================${NC}"

# Navigate to deployment directory
cd "$DEPLOY_PATH" || {
    echo -e "${RED}Deployment path not found: $DEPLOY_PATH${NC}"
    exit 1
}

echo -e "${YELLOW}[1/3] Pulling latest changes from Git...${NC}"
git pull origin "$BRANCH"

echo -e "${YELLOW}[2/3] Installing dependencies...${NC}"
npm install

echo -e "${YELLOW}[3/3] Building application...${NC}"
npm run build

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Deployed at: $(date)"
echo -e "Branch: $BRANCH"
echo -e "Commit: $(git rev-parse --short HEAD)"
