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

// a helper function to lookup environment variables in a compatible manner with the official Docker image
if ( ! function_exists( 'getenv_docker' ) ) {
	// https://github.com/docker-library/wordpress/issues/588 (WP-CLI will load this file 2x)
	function getenv_docker( $wordpress_env, $env, $default = null ) {
		if ( null === $default ) {
			$default = $env;
			$env     = '';
		}

		if ( $fileEnv = getenv( $wordpress_env . '_FILE' ) ) {
			return rtrim( file_get_contents( $fileEnv ), "\r\n" );
		} elseif ( ( $val = getenv( $wordpress_env ) ) !== false ) {
			return $val;
		} elseif ( ! empty( $env ) && ( $val = getenv( $env ) ) !== false ) {
			return $val;
		} else {
			return $default;
		}
	}
}

/**
 * Set up our global environment constant and load its config first
 * Default: production
 */
define( 'WP_ENV', getenv( 'WP_ENV' ) ?: 'production' );

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv_docker( 'WORDPRESS_DB_NAME', 'DB_NAME', 'wordpress' ) );

/** MySQL database username */
define( 'DB_USER', getenv_docker( 'WORDPRESS_DB_USER', 'DB_USER', 'root' ) );

/** MySQL database password */
define( 'DB_PASSWORD', getenv_docker( 'WORDPRESS_DB_PASSWORD', 'DB_PASSWORD', '' ) );

/** MySQL hostname */
define( 'DB_HOST', getenv_docker( 'WORDPRESS_DB_HOST', 'DB_HOST', 'localhost' ) );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', getenv_docker( 'WORDPRESS_DB_CHARSET', 'DB_CHARSET', 'utf8' ) );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', getenv_docker( 'WORDPRESS_DB_COLLATE', 'DB_COLLATE', '' ) );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY', getenv_docker( 'WORDPRESS_AUTH_KEY', 'AUTH_KEY', 'put your unique phrase here' ) );
define( 'SECURE_AUTH_KEY', getenv_docker( 'WORDPRESS_SECURE_AUTH_KEY', 'SECURE_AUTH_KEY', 'put your unique phrase here' ) );
define( 'LOGGED_IN_KEY', getenv_docker( 'WORDPRESS_LOGGED_IN_KEY', 'LOGGED_IN_KEY', 'put your unique phrase here' ) );
define( 'NONCE_KEY', getenv_docker( 'WORDPRESS_NONCE_KEY', 'NONCE_KEY', 'put your unique phrase here' ) );
define( 'AUTH_SALT', getenv_docker( 'WORDPRESS_AUTH_SALT', 'AUTH_SALT', 'put your unique phrase here' ) );
define( 'SECURE_AUTH_SALT', getenv_docker( 'WORDPRESS_SECURE_AUTH_SALT', 'SECURE_AUTH_SALT', 'put your unique phrase here' ) );
define( 'LOGGED_IN_SALT', getenv_docker( 'WORDPRESS_LOGGED_IN_SALT', 'LOGGED_IN_SALT', 'put your unique phrase here' ) );
define( 'NONCE_SALT', getenv_docker( 'WORDPRESS_NONCE_SALT', 'NONCE_SALT', 'put your unique phrase here' ) );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = getenv_docker( 'WORDPRESS_TABLE_PREFIX', 'DB_PREFIX', 'wp_' );

/**
 * Allow WordPress to detect HTTPS when used behind a reverse proxy or a load balancer
 * See https://codex.wordpress.org/Function_Reference/is_ssl#Notes
 *
 * we include this by default because reverse proxying is extremely common in container environments
 */
if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https' ) {
	$_SERVER['HTTPS'] = 'on';
}


if ( defined( 'WP_CLI' ) && WP_CLI && ! isset( $_SERVER['HTTP_HOST'] ) ) {
	$_SERVER['HTTP_HOST'] = parse_url( getenv( 'WP_HOME' ) ?: getenv( 'WP_SITEURL' ), PHP_URL_HOST );
}

if ( $configExtra = getenv_docker( 'WORDPRESS_CONFIG_EXTRA', '' ) ) {
	eval( $configExtra );
}

$user_config = dirname( __DIR__ ) . '/config/wp-config.php';
if ( file_exists( $user_config ) ) {
	require_once $user_config;
}

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', (bool) getenv_docker( 'WORDPRESS_DEBUG', '' ) );
}

if ( defined( 'WP_CLI' ) && WP_CLI && ! isset( $_SERVER['HTTP_HOST'] ) ) {
	$_wp_cli_detected_host = parse_url( defined( 'WP_HOME' ) ? WP_HOME : '', PHP_URL_HOST );

	if ( empty( $_wp_cli_detected_host ) ) {
		$_wp_cli_detected_host = parse_url( defined( 'WP_SITEURL' ) ? WP_SITEURL : '', PHP_URL_HOST );
	}

	if ( empty( $_wp_cli_detected_host ) ) {
		$_wp_cli_detected_host = parse_url( getenv( 'WP_HOME' ) ?: getenv( 'WP_SITEURL' ), PHP_URL_HOST );
	}

	if ( empty( $_wp_cli_detected_host ) ) {
		trigger_error( 'Unable to detect HTTP_HOST for WP-CLI. You must either set WP_HOME and WP_SITEURL environment variables of use --url argument when calling WP-CLI.', E_USER_ERROR );
		exit( 1 );
	}

	$_SERVER['HTTP_HOST'] = $_wp_cli_detected_host;
	unset( $_wp_cli_detected_host );
}

$scheme = 'http://';
if ( isset( $_SERVER['HTTPS'] ) && 'on' === $_SERVER['HTTPS'] ) {
	$scheme = 'https://';
}
if ( ! defined( 'WP_HOME' ) ) {
	define( 'WP_HOME', rtrim( getenv( 'WP_HOME' ) ?: $scheme . $_SERVER['HTTP_HOST'], '/' ) );
}
if ( ! defined( 'WP_SITEURL' ) ) {
	define( 'WP_SITEURL', rtrim( getenv( 'WP_SITEURL' ), '/' ) ?: WP_HOME . '/wp' );
}
unset( $scheme );

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
	define( 'DISALLOW_FILE_EDIT', 'true' === strtolower( getenv( 'DISALLOW_FILE_EDIT' ) ?: 'true' ) );
}
if ( ! defined( 'DISALLOW_FILE_MODS' ) ) {
	// Disable plugin and theme updates and installation from the admin
	define( 'DISALLOW_FILE_MODS', 'true' === strtolower( getenv( 'DISALLOW_FILE_MODS' ) ?: 'true' ) );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/wp/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
