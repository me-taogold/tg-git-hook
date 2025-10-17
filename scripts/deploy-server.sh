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
echo -e "Target path: $DEPLOY_PATH"
echo ""

# Check if deployment path exists
if [ ! -d "$DEPLOY_PATH" ]; then
    echo -e "${RED}ERROR: Deployment path not found: $DEPLOY_PATH${NC}"
    echo -e "${RED}Please ensure the project directory exists${NC}"
    exit 1
fi

# Navigate to deployment directory
cd "$DEPLOY_PATH" || {
    echo -e "${RED}ERROR: Cannot access deployment path: $DEPLOY_PATH${NC}"
    exit 1
}

echo -e "${YELLOW}[1/3] Pulling latest changes from Git...${NC}"
if git pull origin "$BRANCH"; then
    echo -e "${GREEN}✓ Git pull successful${NC}"
else
    echo -e "${RED}✗ Git pull failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/3] Installing dependencies...${NC}"
if npm install; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ npm install failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[3/3] Building application...${NC}"
if npm run build; then
    echo -e "${GREEN}✓ Build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Deployed at: $(date)"
echo -e "Branch: $BRANCH"
echo -e "Commit: $(git rev-parse --short HEAD)"
echo ""
