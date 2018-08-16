<?php
$BUILTIN_EXTENSIONS = array(
	new BuiltinExtension('exif'),
	new BuiltinExtension('gd',
		array(
			'libfreetype6-dev',
			'libjpeg62-turbo-dev',
			'libpng-dev',
			'libwebp-dev'
		),
		array(
        	'--with-freetype-dir=/usr/include/',
        	'--with-jpeg-dir=/usr/include/',
        	'--with-png-dir=/usr/include/',
        	'--with-webp-dir=/usr/include/',
		)
	),
	new BuiltinExtension('imap',
		array(
			'libc-client-dev',
 			'libkrb5-dev',
		),
		array(
			'--with-kerberos',
 		   	'--with-imap-ssl',
		)
	),
	new BuiltinExtension('intl', array('libicu-dev', 'zlib1g-dev')),
	new BuiltinExtension('gettext'),
	new BuiltinExtension('mcrypt', array('libmcrypt-dev')),
	new BuiltinExtension('mysqli'),
	new BuiltinExtension('opcache'),
	new BuiltinExtension('shmop'),
	new BuiltinExtension('soap'),
	new BuiltinExtension('tidy', array('libtidy-dev')),
	new BuiltinExtension('xmlrpc'),
	new BuiltinExtension('xsl', array('libxslt-dev')),
	new BuiltinExtension('zip', array('zlib1g-dev')),
);

$PECL_EXTENSIONS = array(
	// install apcu before serializers so that they detect and enable support for it
	new PeclExtension('apcu', array(), array(), '5.1.2'),
	new PeclExtension('apcu_bc', array(), array(), '1.0.4', 'apc'),

	// install serializers to make them available for the rest of the extensions
	new PeclExtension('igbinary', array(), array(), '2.0.7'),
	new PeclExtension('msgpack', array(), array(), '2.0.2'),

	// install "regular" extensions
	new PeclExtension('grpc', array(), array(), '1.14.1'),
	new PeclExtension('imagick', array('libmagickwand-dev'), array(), '3.4.3', 'imagick', 'imagick', array('ghostscript')),
	new PeclExtension('mailparse', array(), array(), '3.0.2'),
	new PeclExtension('memcached', array('libmemcached-dev', 'zlib1g-dev'), array('--enable-memcached-igbinary', '--enable-memcached-msgpack', '--enable-memcached-json'), '3.0.4'),
	new PeclExtension('oauth', array('libpcre3-dev'), array(), '2.0.2'),
	new PeclExtension('opencensus', array(), array(), '0.2.2'),
	new PeclExtension('protobuf', array(), array(), '3.6.1'),
	new PeclExtension('redis', array(), array('--enable-redis-igbinary', '--enable-redis-lzf'), '4.1.1'),
	new PeclExtension('yaml', array('libyaml-dev'), array(), '2.0.2'),
);

function _install_build_deps( $dryRun ) {
	global $BUILTIN_EXTENSIONS, $PECL_EXTENSIONS;
	$extensions = array_merge($BUILTIN_EXTENSIONS, $PECL_EXTENSIONS);
	$buildDeps = array();
	foreach ( $extensions as $ext ) {
		$buildDeps = array_unique(array_merge( $buildDeps, $ext->getBuildDependencies(), $ext->getExtraDependencies() ));
	}
	if ( count( $buildDeps ) > 0 ) {
		run(array_merge(array('apt-get', 'install', '--no-install-recommends', '-y'), $buildDeps), $dryRun);
		run(array_merge(array('apt-mark', 'auto'), $buildDeps), $dryRun);
	}
}

function _mark_runtime_dependencies( $dryRun ) {
	global $BUILTIN_EXTENSIONS, $PECL_EXTENSIONS;
	$extensions = array_merge($BUILTIN_EXTENSIONS, $PECL_EXTENSIONS);
	$pkgs = array();
	foreach ( $extensions as $ext ) {
		$pkgs = array_merge( $pkgs, $ext->getExtraDependencies() );
	}

	$libs = array();
	run(array('find', PHP_EXTENSION_DIR,'-type', 'f', '-name', '*.so'), $dryRun, false, $libs);

	$libFiles = array();
	foreach ( $libs as $lib ) {
		run(array('ldd', $lib), $dryRun, false, $libDeps);
		foreach( $libDeps as $libDep ) {
			if ( strpos( $libDep, "=>" ) !== false ) {
				$libDep = preg_replace('/\s+/i', ' ', trim($libDep));
				$_l = explode( " ", $libDep );
				$libFiles[] = $_l[ count($_l) - 2 ]; 
			}
		}
	}
	$libFiles = array_unique($libFiles);

	foreach ( $libFiles as $libFile ) {
		$pkg = run(array('dpkg-query', '-S', $libFile), $dryRun, false);
		$pkg = preg_replace('/^([^:]+):.*$/s', '$1', $pkg);
		$pkgs[] = $pkg;
	}
	$pkgs = array_unique( $pkgs );

	run(array_merge(array('apt-mark', 'manual'), $pkgs), $dryRun);
}

function _clean_up( $dryRun ) {
	global $BUILTIN_EXTENSIONS, $PECL_EXTENSIONS;
	$extensions = array_merge($BUILTIN_EXTENSIONS, $PECL_EXTENSIONS);
	$buildDeps = array();
	foreach ( $extensions as $ext ) {
		$buildDeps = array_unique(array_merge( $buildDeps, $ext->getBuildDependencies() ));
	}
	if ( count( $buildDeps ) > 0 ) {
		run(array_merge(array('apt-get', 'autoremove', '-y', '--purge'), $buildDeps), $dryRun);
	}
}

function install_extensions( $dryRun ) {
	global $BUILTIN_EXTENSIONS, $PECL_EXTENSIONS;
	log_msg("Installing build time dependencies...");
	_install_build_deps( $dryRun );

	log_msg("Installing built-in extensions...");
	foreach ($BUILTIN_EXTENSIONS as $ext) {
		$ext->install( $dryRun );
	}

	log_msg("Installing pecl extensions...");
	foreach ($PECL_EXTENSIONS as $ext) {
		$ext->install( $dryRun );
	}

	log_msg("Marking runtime dependencies...");
	_mark_runtime_dependencies( $dryRun );

	log_msg("Cleaning up...");
	_clean_up( $dryRun );
}
