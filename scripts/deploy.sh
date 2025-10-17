#!/bin/bash

################################################################################
# Deployment Script
# Pulls latest code from Git and builds the application
################################################################################

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to project root (parent of scripts directory)
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting deployment${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Project directory: $PROJECT_DIR"

# Navigate to project directory
cd "$PROJECT_DIR" || {
    echo -e "${RED}Failed to navigate to project directory: $PROJECT_DIR${NC}"
    exit 1
}

echo -e "${YELLOW}[1/3] Pulling latest changes from Git...${NC}"
git pull || {
    echo -e "${RED}Git pull failed${NC}"
    exit 1
}

echo -e "${YELLOW}[2/3] Installing dependencies...${NC}"
npm install || {
    echo -e "${RED}npm install failed${NC}"
    exit 1
}

echo -e "${YELLOW}[3/3] Building application...${NC}"
npm run build || {
    echo -e "${RED}npm run build failed${NC}"
    exit 1
}

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "Deployed at: $(date)"
echo -e "Commit: $(git rev-parse --short HEAD)"
