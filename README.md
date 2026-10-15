# CivicConnect — Headless Drupal 11 API Backend

![Drupal 11](https://img.shields.io/badge/Drupal-11.0-blue.svg?logo=drupal)
![PHP](https://img.shields.io/badge/PHP-8.3--FPM-777BB4.svg?logo=php)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg?logo=docker)
![JSON:API](https://img.shields.io/badge/API-JSON%3AAPI%20Spec%201.0-FF6C37.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

> **CivicConnect** is a headless Drupal 11 content management backend powering the CivicConnect council services portal. It exposes structured content via the standard JSON:API specification for high-performance consumption by a decoupled Next.js 14 frontend, built to modern Australian government standards (WCAG 2.1 AA accessibility, Victorian Protective Data Security Standards / VPDSS).

---

## 🏛️ Project Overview

CivicConnect provides an enterprise-ready, headless CMS backend designed for local government authorities (e.g. City of Greater Geelong). It centralises municipal service directories, civic news releases, and community events into structured, typed entity models. By completely decoupling the Drupal presentation layer, content editors retain Drupal’s world-class publishing workflows and revision management while digital teams can deliver instant-loading, accessible frontend experiences via Next.js and Vercel/edge networks.

---

## 📐 System Architecture

The following diagram illustrates the decoupled architecture from editorial input down to resident-facing presentation:

```text
+-----------------------------------------------------------------------------------+
|                        City of Greater Geelong CMS Layer                          |
|                                                                                   |
|  [ Content Editors & Public Information Officers ]                               |
|                         │                                                         |
|                         ▼                                                         |
|   +───────────────────────────────────────────────+                               |
|   |         Drupal 11 Headless CMS Core           |                               |
|   |  - Role-based workflows & revision log        |                               |
|   |  - Structured Entity Bundles:                 |                               |
|   |      • Services (FOGO, Parking, Rates, etc.)  |                               |
|   |      • News Articles (Civic announcements)    |                               |
|   |      • Events (Town halls, festivals, expos)  |                               |
|   |  - OAuth 2.0 / JWT Authentication             |                               |
|   |  - Automated Metatag & Pathauto Aliasing      |                               |
|   +──────────────────────┬────────────────────────+                               |
+──────────────────────────┼────────────────────────────────────────────────────────+
                           │
                           │  HTTP / JSON:API v1.0 (RESTful over TLS)
                           │  CORS: Allowed Origin http://localhost:3000
                           ▼
+-----------------------------------------------------------------------------------+
|                          JSON:API Endpoints Specification                         |
|                                                                                   |
|  GET /jsonapi/node/service?include=field_media&sort=-created                     |
|  GET /jsonapi/node/news_article?filter[status]=1&page[limit]=10                   |
|  GET /jsonapi/node/event?sort=field_event_date                                    |
+-----------------------------------------------------------------------------------+
                           │
                           │  ISR (Incremental Static Regeneration) & Cache Tags
                           ▼
+-----------------------------------------------------------------------------------+
|                       Decoupled Presentation Layer                                |
|                                                                                   |
|   +───────────────────────────────────────────────+                               |
|   |             Next.js 14 App Router             |                               |
|   |  - Server-Side Rendering (SSR) & Edge Caching |                               |
|   |  - WCAG 2.1 AA Compliant Design System        |                               |
|   |  - Fully Accessible Geelong Civic Portal      |                               |
|   +──────────────────────┬────────────────────────+                               |
|                          │                                                        |
|                          ▼                                                        |
|               [ Geelong Community & Residents ]                                  |
+-----------------------------------------------------------------------------------+
```

---

## 💻 Tech Stack

| Component | Technology | Version / Specification | Role in Architecture |
|---|---|---|---|
| **Core CMS** | Drupal | 11.0.x | Content modelling, editorial workflows, REST/JSON:API engine |
| **Runtime** | PHP | 8.3-FPM | High performance execution with JIT and OPcache |
| **Database** | MySQL | 8.0.x | Relational storage for entity tables with utf8mb4 collation |
| **Web Server** | Nginx | 1.25 Alpine | Reverse proxy, static asset cache, FastCGI handler, SSL termination |
| **API Protocol** | JSON:API | 1.0 (OAS compliant) | Zero-overhead, standard entity data interchange format |
| **Authentication**| Simple OAuth | 5.x / 6.x | RFC 6749 compliant OAuth 2.0 bearer token authorization |
| **Mail Testing** | MailHog | Latest | Local SMTP capture server with browser GUI |
| **Containers** | Docker Compose | v2.x | Multi-container reproducible development environment |
| **CI / CD** | GitHub Actions | Ubuntu Latest | Automated PHPCS (Drupal standards), PHPStan, and config audit |

---

## 🚀 Quick Start Guide

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/)
- Git

### 1. Clone & Initialize Environment
```bash
# Clone the repository
git clone https://github.com/sushmagogula/civic-connect-drupal.git
cd civic-connect-drupal

# Copy environment variables
cp .env.example .env
```

### 2. Launch Docker Containers
```bash
docker compose up -d
```
Container status:
- **Nginx Web Server:** [http://localhost:8080](http://localhost:8080)
- **Drupal Backend Admin:** [http://localhost:8080/user/login](http://localhost:8080/user/login)
- **MailHog Web Inbox:** [http://localhost:8025](http://localhost:8025)
- **MySQL Database:** `localhost:3306`

### 3. Run Automated Site Installation
Execute the automated setup script to run Composer install, initialize MySQL tables, run `drush site:install`, and enable required modules:
```bash
./scripts/setup.sh
```
*Default Admin Credentials:* `Username: admin` / `Password: admin123`

### 4. Seed Greater Geelong Civic Content
Populate the database with realistic civic services, news bulletins, and community events:
```bash
./scripts/seed-content.sh
```

---

## 📡 JSON:API Endpoints Reference

All structured content is instantly queryable via JSON:API out-of-the-box:

| Resource | JSON:API Endpoint URL | Sample Query Filter |
|---|---|---|
| **Municipal Services** | `/jsonapi/node/service` | `?fields[node--service]=title,body,summary` |
| **News Articles** | `/jsonapi/node/news_article` | `?sort=-created&page[limit]=4` |
| **Community Events** | `/jsonapi/node/event` | `?filter[status][value]=1` |
| **API Entry Point** | `/jsonapi` | Complete resource index |

### Sample JSON:API Response
```json
{
  "jsonapi": {
    "version": "1.0",
    "meta": {
      "links": {
        "self": { "href": "http://jsonapi.org/format/1.0/" }
      }
    }
  },
  "data": [
    {
      "type": "node--service",
      "id": "e4c84fd2-89fa-47cb-95a2-f286e6dbfa81",
      "attributes": {
        "title": "Waste Collection & Resource Recovery",
        "status": true,
        "body": {
          "value": "<p>The City of Greater Geelong provides comprehensive waste management...</p>",
          "summary": "Residential kerbside waste, yellow recycling, and FOGO organics..."
        }
      }
    }
  ]
}
```

---

## 🧩 Modules Used & Rationale

| Module | Purpose & Production Rationale |
|---|---|
| **jsonapi** | Core Drupal module exposing standard JSON:API 1.0 specifications without extra module bloat. |
| **jsonapi_extras** | Provides granular overrides for resource paths, field naming aliases, and disabled sensitive fields. |
| **simple_oauth** | Implements OAuth 2.0 authorization server (RFC 6749) allowing the Next.js frontend to securely perform mutations. |
| **metatag** | Structured OpenGraph, Twitter Cards, and schema.org metadata delivered straight to the headless frontend. |
| **paragraphs** | Flexible component-based page building allowing editors to assemble structured content slices. |
| **pathauto** | Automated, human-friendly URL alias generation adhering to council SEO standards. |
| **redirect** | Handles 301/302 redirects seamlessly so legacy council URLs automatically redirect in the frontend. |
| **token** | Provides token substitution engine for automated paths, metatags, and system labels. |

---

## ⚙️ Configuration Management

CivicConnect follows strict Drupal Configuration Management (CMI) best practices:
- All site configuration is exported outside the webroot into `config/sync/`.
- No configuration is modified directly in production databases.
- Configuration deployment pipeline:
  ```bash
  # Export configuration after making administrative changes
  docker compose exec php drush config:export -y

  # Import configuration on deployment environments
  docker compose exec php drush config:import -y
  ```

---

## 🔄 CI / CD Pipeline

The repository includes a automated GitHub Actions workflow (`.github/workflows/ci.yml`):
- **PHP CodeSniffer (`phpcs`):** Enforces strict `Drupal` and `DrupalPractice` coding standards on all custom code in `web/modules/custom`.
- **PHPStan:** Static code analysis verifying type safety and deprecation prevention for Drupal 11.
- **Config Sync Verification:** Asserts that exported configuration in `config/sync` has zero untracked differences.

---

## 👤 Developer

**Sushma Gogula**  
*Senior Drupal Developer*  
Portfolio Project for City of Greater Geelong (Band 7 Role Application)  
Contact: [gsushma511@gmail.com](mailto:gsushma511@gmail.com)
