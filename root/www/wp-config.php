<?php // vim: set backupcopy=yes:
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

$getenv = function ( $name, $default ) {
	$v = getenv( $name );
	if ( false === $v ) {
		$v = $default;
	}
	return "$v";
};

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', $getenv( 'WORDPRESS_DB_NAME', 'wordpress') );

/** MySQL database username */
define( 'DB_USER', $getenv( 'WORDPRESS_DB_USER', 'root') );

/** MySQL database password */
define( 'DB_PASSWORD', $getenv( 'WORDPRESS_DB_PASSWORD', '') );

/** MySQL hostname */
define( 'DB_HOST', $getenv( 'WORDPRESS_DB_HOST', 'localhost') );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', $getenv( 'WORDPRESS_DB_CHARSET', 'utf8mb4' ) );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', $getenv( 'WORDPRESS_DB_COLLATE', '' ) );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

/**#@-*/

/** Disable wp-cron since we are triggering it externally */
define('DISABLE_WP_CRON', true);

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = $getenv( 'WORDPRESS_DB_TABLE_PREFIX', 'wp_' );

define( 'FS_METHOD', 'direct' ); // always use direct filesystem access for installs

define( 'WP_DEBUG', true );

/* That's all, stop editing! Happy blogging. */
unset( $getenv );

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
