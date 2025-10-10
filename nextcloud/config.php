<?php
$CONFIG = array (
  'instanceid' => 'ocxxxxxxxxxx',  // You can leave this or generate it
  'passwordsalt' => 'k2W9smwezdGqkNVYAYsb',
  'secret' => '5B1C4DF6B60A0F3BE66403363524DA9D',
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => '127.0.0.1',
    2 => 'nextcloud.neburware.com',  // Add your actual domain or IP
  ),
  'datadirectory' => '/mnt/sda1/shared',
  'dbtype' => 'mysql',
  'version' => '29.0.0.0',
  'overwrite.cli.url' => 'https://nextcloud.neburware.com',
  'overwritehost' => 'nextcloud.neburware.com',
  'overwriteprotocol' => 'https',
  'trusted_proxies' =>
  array (
    0 => 'nginx_proxy',  // Name of the reverse proxy container
  ),
  'dbname' => 'nextcloud_db',
  'dbhost' => 'db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud_user',
  'dbpassword' => 'XfZj6JVpZyaYl08fMh6r',
  'installed' => true,

  // Optional Redis cache (requires redis container)
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => array(
     'host' => 'nextcloud_redis',
     'port' => 6379,
  ),

  // Logging
  'loglevel' => 2,
  'logtimezone' => 'UTC',
  'trusted_proxies' => ['nginx_proxy'],
  'overwrite.cli.url' => 'https://nextcloud.neburware.com',
  'overwritehost' => 'nextcloud.neburware.com',
  'overwriteprotocol' => 'https'
);
