# CivicConnect — Headless Drupal 11 CMS Starter Kit

[![Drupal](https://img.shields.io/badge/Drupal-11-0678BE?style=flat-square&logo=drupal&logoColor=white)](https://www.drupal.org)
[![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docker.com)
[![JSON:API](https://img.shields.io/badge/JSON%3AAPI-Enabled-success?style=flat-square)](https://jsonapi.org)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

A headless **Drupal 11** backend starter kit exposing structured content via **JSON:API** for modern decoupled frontends. Designed as a reference implementation for civic and community service portals.

> Pairs with [civic-connect-frontend](https://github.com/sushmag-au/civic-connect-frontend) — a Next.js 14 App Router frontend.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Content Editors                     │
│              Drupal Admin UI (:8080)                 │
└───────────────────────┬─────────────────────────────┘
                        │
              ┌─────────▼──────────┐
              │   Drupal 11 CMS    │
              │  JSON:API Module   │
              │  Simple OAuth      │
              │  Metatag + Pathauto│
              └─────────┬──────────┘
                        │ JSON:API
              ┌─────────▼──────────┐
              │  Next.js 14 UI     │
              │  (:3000)           │
              └────────────────────┘
```

## Features

- **Drupal 11** fully Dockerised (PHP 8.3-FPM, Nginx, MySQL 8, Mailhog)
- **JSON:API** — content exposed at standard endpoints with filtering and pagination
- **Simple OAuth** — token-based authentication for protected mutations
- **Metatag + Pathauto** — SEO-friendly metadata and clean URL aliases
- **Paragraphs** — flexible content composition for rich page layouts
- **CORS configured** for Next.js frontend at `localhost:3000`
- **Config management** — all config committed to `config/sync/` for version control
- **Drush scripts** — one-command site install and content seeding

## Tech Stack

| Component | Technology |
|-----------|------------|
| CMS | Drupal 11 |
| Language | PHP 8.3 |
| API | JSON:API (Drupal core) |
| Auth | Simple OAuth 2.0 |
| Database | MySQL 8.0 |
| Container | Docker + Docker Compose |
| Web server | Nginx |
| CI/CD | GitHub Actions |

## JSON:API Endpoints

| Content Type | Endpoint |
|-------------|----------|
| Services | `GET /jsonapi/node/service` |
| News Articles | `GET /jsonapi/node/news_article` |
| Events | `GET /jsonapi/node/event` |

All endpoints support JSON:API filtering: `?filter[field_service_category.name]=Environment`

## Modules

| Module | Purpose |
|--------|---------|
| `jsonapi` | Core JSON:API support |
| `jsonapi_extras` | Endpoint customisation and field aliasing |
| `simple_oauth` | OAuth 2.0 / JWT token authentication |
| `metatag` | SEO meta tags driven from content fields |
| `pathauto` | Automatic clean URL alias generation |
| `paragraphs` | Flexible component-based content composition |
| `redirect` | 301/302 redirect management |
| `token` | Token system for dynamic text |

## Quick Start

```bash
git clone https://github.com/sushmag-au/civic-connect-drupal.git
cd civic-connect-drupal
cp .env.example .env
docker compose up -d
bash scripts/setup.sh
bash scripts/seed-content.sh
```

Drupal admin: http://localhost:8080 (admin / admin)
JSON:API: http://localhost:8080/jsonapi

## Configuration Management

All Drupal configuration is exported to `config/sync/` and version controlled. To import config on a fresh install:
```bash
docker compose exec php drush config:import -y
```

## CI/CD

GitHub Actions runs on every push:
- PHP 8.3 + Composer install
- PHPCS — Drupal coding standards
- PHPStan — static analysis
- Config export diff check

## Developer

**Sushma Gogula** — [github.com/sushmag-au](https://github.com/sushmag-au) · [linkedin.com/in/gsushma-au](https://linkedin.com/in/gsushma-au)
