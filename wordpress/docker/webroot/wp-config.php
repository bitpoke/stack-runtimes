<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

/**
 * Set up our global environment constant and load its config first
 * Default: production
 */
define('WP_ENV', getenv('WP_ENV') ?: 'production');

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv('DB_NAME') ?: 'wordpress' );

/** MySQL database username */
define( 'DB_USER', getenv('DB_USER') ?: '' );

/** MySQL database password */
define( 'DB_PASSWORD', getenv('DB_PASSWORD') ?: '' );

/** MySQL hostname */
define( 'DB_HOST', getenv('DB_HOST') ?: 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', getenv( 'DB_CHARSET' ) ?: 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', getenv( 'DB_COLLATE' ) ?: '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         getenv( 'AUTH_KEY' ) ?: 'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  getenv( 'SECURE_AUTH_KEY' ) ?: 'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    getenv( 'LOGGED_IN_KEY' ) ?: 'put your unique phrase here' );
define( 'NONCE_KEY',        getenv( 'NONCE_KEY' ) ?: 'put your unique phrase here' );
define( 'AUTH_SALT',        getenv( 'AUTH_SALT' ) ?: 'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', getenv( 'SECURE_AUTH_SALT' ) ?: 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   getenv( 'LOGGED_IN_SALT' ) ?: 'put your unique phrase here' );
define( 'NONCE_SALT',       getenv( 'NONCE_SALT' ) ?: 'put your unique phrase here' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = getenv('DB_PREFIX') ?: 'wp_';

define( 'WP_HOME', rtrim( getenv( 'WP_HOME' ) ?: 'http://' . $_SERVER['HTTP_HOST'], '/' ) );
define( 'WP_SITEURL', rtrim( getenv( 'WP_SITEURL' ), '/' ) ?: WP_HOME . '/wp' );

/**
 * Allow WordPress to detect HTTPS when used behind a reverse proxy or a load balancer
 * See https://codex.wordpress.org/Function_Reference/is_ssl#Notes
 */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

$user_config = dirname( __DIR__ ) . '/config/wp-config.php';

if ( file_exists( $user_config ) ) {
    require_once $user_config;
}

if ( ! defined( 'CONTENT_DIR' ) ) {
	define( 'CONTENT_DIR', '/wp-content' );
}

if ( ! defined( 'WP_CONTENT_DIR' ) ) {
	define( 'WP_CONTENT_DIR', __DIR__ . CONTENT_DIR );
}

if ( ! defined( 'WP_CONTENT_URL' ) ) {
	define( 'WP_CONTENT_URL', WP_HOME . CONTENT_DIR );
}

/**
 * Custom Settings
 */
if ( ! defined( 'AUTOMATIC_UPDATER_DISABLED' ) ) {
	define( 'AUTOMATIC_UPDATER_DISABLED', true );
}
if ( ! defined( 'DISABLE_WP_CRON' ) ) {
	define( 'DISABLE_WP_CRON', getenv( 'DISABLE_WP_CRON' ) ?: false );
}
if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	// Disable the plugin and theme file editor in the admin
	define( 'DISALLOW_FILE_EDIT', "true" === strtolower( getenv( 'DISALLOW_FILE_EDIT' ) ?: "true" ) );
}
if ( ! defined( 'DISALLOW_FILE_MODS' ) ) {
	// Disable plugin and theme updates and installation from the admin
	define( 'DISALLOW_FILE_MODS', "true" === strtolower( getenv( 'DISALLOW_FILE_MODS' ) ?: "true" ) );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/wp/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
