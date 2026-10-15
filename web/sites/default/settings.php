<?php

/**
 * @file
 * Drupal 11 configuration settings for CivicConnect headless backend.
 *
 * Configured for City of Harborview Civic Portal decoupled architecture.
 *
 * @see https://api.drupal.org/api/drupal/core!assets!scaffold!files!default.settings.php/11
 */

use Drupal\Core\Database\Database;

// Database Configuration reading from Environment Variables
$databases['default']['default'] = [
  'database' => getenv('MYSQL_DATABASE') ?: 'drupal',
  'username' => getenv('MYSQL_USER') ?: 'drupal',
  'password' => getenv('MYSQL_PASSWORD') ?: 'drupal',
  'prefix' => getenv('MYSQL_PREFIX') ?: '',
  'host' => getenv('MYSQL_HOST') ?: 'db',
  'port' => getenv('MYSQL_PORT') ?: '3306',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'driver' => 'mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_unicode_ci',
];

// Configuration Sync Directory (version controlled outside webroot)
$settings['config_sync_directory'] = '../config/sync';

// Drupal Hash Salt
$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT') ?: 'civicconnect-geelong-band7-drupal11-portfolio-secure-salt-2026';

// Trusted Host Patterns
$settings['trusted_host_patterns'] = [
  '^localhost$',
  '^127\.0\.0\.1$',
  '^nginx$',
  '^php$',
  '^civicconnect_nginx$',
  '^.*\.local$',
];

// File System Paths
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = '../private';
$settings['file_temp_path'] = '/tmp';

// Update Free Access
$settings['update_free_access'] = FALSE;

// Entity Update Backup
$settings['entity_update_backup'] = TRUE;

// Migrate Node Variant Migration
$settings['migrate_node_variant'] = TRUE;

// Simple OAuth Keys Configuration
$settings['simple_oauth.public_key'] = getenv('SIMPLE_OAUTH_PUBLIC_KEY') ?: '../keys/public.key';
$settings['simple_oauth.private_key'] = getenv('SIMPLE_OAUTH_PRIVATE_KEY') ?: '../keys/private.key';

// Cross-Origin Resource Sharing (CORS) for Decoupled Next.js Frontend
$settings['cors.config'] = [
  'enabled' => TRUE,
  'allowedHeaders' => [
    'Authorization',
    'Content-Type',
    'Accept',
    'Origin',
    'X-Requested-With',
    'X-CSRF-Token',
  ],
  'allowedMethods' => ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD'],
  'allowedOrigins' => [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
  ],
  'exposedHeaders' => ['Content-Type', 'X-CSRF-Token'],
  'maxAge' => 3600,
  'supportsCredentials' => TRUE,
];

// JSON:API Extras Settings
$settings['jsonapi_extras.include_count'] = TRUE;

// Load local settings if present
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}

// Load local services if present
if (file_exists($app_root . '/' . $site_path . '/services.local.yml')) {
  $settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.local.yml';
}
