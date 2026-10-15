#!/usr/bin/env bash
# ==============================================================================
# CivicConnect - Automated Setup Script
# Drupal 11 Headless Backend for City of Greater Geelong
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${CYAN}   CivicConnect - City of Greater Geelong Drupal 11 Setup       ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Detect if running inside Docker container or host
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
  RUN_PREFIX=""
  PROJECT_ROOT="/var/www/html"
else
  # Running from host machine
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
  
  # Check if docker compose is running
  if command -v docker >/dev/null 2>&1 && docker compose ps civicconnect_php 2>/dev/null | grep -q "Up"; then
    echo -e "${CYAN}Detected running Docker environment. Executing inside civicconnect_php container...${NC}"
    docker compose exec -T php /var/www/html/scripts/setup.sh
    exit $?
  fi
  RUN_PREFIX=""
fi

cd "$PROJECT_ROOT"

# Step 1: Install Composer Dependencies
echo -e "\n${YELLOW}[1/6] Installing Composer dependencies (Drupal 11 & Contrib)...${NC}"
if command -v composer >/dev/null 2>&1; then
  composer install --no-interaction --prefer-dist --optimize-autoloader
else
  echo -e "${RED}Error: Composer is not installed.${NC}" >&2
  exit 1
fi

# Step 2: Generate OAuth Keys for simple_oauth if not already present
echo -e "\n${YELLOW}[2/6] Configuring Simple OAuth JWT encryption keys...${NC}"
mkdir -p keys
if [ ! -f keys/private.key ] || [ ! -f keys/public.key ]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl genrsa -out keys/private.key 2048 2>/dev/null
    openssl rsa -in keys/private.key -pubout -out keys/public.key 2>/dev/null
    chmod 600 keys/private.key
    chmod 644 keys/public.key
    echo -e "${GREEN}✓ Generated private.key and public.key in /keys directory.${NC}"
  else
    echo -e "${YELLOW}Warning: OpenSSL not found. Please generate keys manually.${NC}"
  fi
else
  echo -e "${GREEN}✓ Simple OAuth keys already present.${NC}"
fi

# Step 3: Wait for MySQL Database
echo -e "\n${YELLOW}[3/6] Waiting for MySQL database connection...${NC}"
DB_HOST="${MYSQL_HOST:-db}"
DB_PORT="${MYSQL_PORT:-3306}"
DB_USER="${MYSQL_USER:-drupal}"
DB_PASS="${MYSQL_PASSWORD:-drupal}"

MAX_TRIES=30
COUNT=0
until (echo > /dev/tcp/"$DB_HOST"/"$DB_PORT") >/dev/null 2>&1 || [ "$COUNT" -ge "$MAX_TRIES" ]; do
  COUNT=$((COUNT + 1))
  echo -e "Waiting for database at ${DB_HOST}:${DB_PORT} ($COUNT/$MAX_TRIES)..."
  sleep 2
done

if [ "$COUNT" -ge "$MAX_TRIES" ]; then
  echo -e "${RED}Error: Unable to connect to database at ${DB_HOST}:${DB_PORT}${NC}" >&2
  exit 1
fi
echo -e "${GREEN}✓ MySQL database is reachable.${NC}"

# Step 4: Run Drupal 11 Site Installation
echo -e "\n${YELLOW}[4/6] Installing Drupal 11 site via Drush...${NC}"
DRUSH="./vendor/bin/drush"
if [ ! -f "$DRUSH" ]; then
  DRUSH="drush"
fi

$DRUSH site:install standard \
  --site-name="CivicConnect | City of Greater Geelong" \
  --site-mail="admin@geelongcity.vic.gov.au" \
  --account-name="admin" \
  --account-pass="admin123" \
  --account-mail="admin@geelongcity.vic.gov.au" \
  --locale="en" \
  --yes

# Step 5: Enable Required Contrib & Core Modules
echo -e "\n${YELLOW}[5/6] Enabling JSON:API and Headless Contrib Modules...${NC}"
REQUIRED_MODULES=(
  jsonapi
  jsonapi_extras
  metatag
  paragraphs
  pathauto
  redirect
  simple_oauth
  token
)

for MODULE in "${REQUIRED_MODULES[@]}"; do
  echo -e "Enabling ${CYAN}${MODULE}${NC}..."
  $DRUSH pm:install "$MODULE" --yes || echo -e "${YELLOW}Module ${MODULE} not yet downloaded or already enabled.${NC}"
done

# Step 6: Import Synchronized Configuration (if available)
echo -e "\n${YELLOW}[6/6] Checking for Synchronized Configuration in config/sync...${NC}"
CONFIG_COUNT=$(find config/sync -name "*.yml" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONFIG_COUNT" -gt 0 ]; then
  echo -e "Found ${CONFIG_COUNT} configuration files. Importing..."
  $DRUSH config:import --yes
else
  echo -e "No existing YAML configuration found in config/sync. Exporting current configuration..."
  $DRUSH config:export --yes || true
fi

# Rebuild Drupal Cache
$DRUSH cache:rebuild

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}   CivicConnect Drupal 11 Setup Completed Successfully!        ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Drupal Backend Admin:  ${CYAN}http://localhost:8080/user/login${NC}"
echo -e "Admin Username:        ${CYAN}admin${NC}"
echo -e "Admin Password:        ${CYAN}admin123${NC}"
echo -e "JSON:API Root:         ${CYAN}http://localhost:8080/jsonapi${NC}"
echo -e "MailHog Inbox:         ${CYAN}http://localhost:8025${NC}"
echo -e "\nNext step: Run ${CYAN}./scripts/seed-content.sh${NC} to populate sample civic services, news, and events."
