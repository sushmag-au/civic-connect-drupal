#!/usr/bin/env bash
# ==============================================================================
# CivicConnect - Git Initialization and Commit Sequence
# Executes the sequential portfolio commits for Sushma Gogula
# ==============================================================================

set -euo pipefail

cd "$(dirname "$0")/.."

# Ensure scripts have execute permissions
chmod +x scripts/*.sh

# Initialize Git repository with main branch
git init -b main

# Configure Git Author
git config user.email "gsushma511@gmail.com"
git config user.name "Sushma Gogula"

# Commit 1: Project Scaffold
git add composer.json .gitignore config/sync/.gitkeep web/modules/custom/.gitkeep phpcs.xml.dist phpstan.neon.dist
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "feat: scaffold Drupal 11 headless project with Composer"

# Commit 2: Docker Environment
git add docker-compose.yml docker/
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "feat: add Docker environment (PHP 8.3, Nginx, MySQL 8)"

# Commit 3: Drupal Settings and CORS
git add web/sites/default/settings.php web/sites/default/services.yml .env.example
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "feat: configure Drupal settings with env vars and CORS for Next.js"

# Commit 4: Setup and Content Seeding Scripts
git add scripts/
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "feat: add setup and content seeding scripts"

# Commit 5: GitHub Actions CI/CD Workflow
git add .github/
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "ci: add GitHub Actions workflow for Drupal coding standards"

# Commit 6: Project Documentation & Architecture
git add README.md
git -c user.email='gsushma511@gmail.com' -c user.name='Sushma Gogula' commit -m "docs: add README with architecture diagram and API endpoint reference"

echo "All 6 Git commits created successfully!"
git log --oneline -n 6
