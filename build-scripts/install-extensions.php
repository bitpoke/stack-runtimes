<?php
require_once dirname( __FILE__ ) . '/src/autoload.php';

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
    new BuiltinExtension('mysqli'),
    new BuiltinExtension('opcache'),
    new BuiltinExtension('pcntl'),
    new BuiltinExtension('shmop'),
    new BuiltinExtension('soap'),
    new BuiltinExtension('tidy', array('libtidy-dev')),
    new BuiltinExtension('xmlrpc'),
    new BuiltinExtension('xsl', array('libxslt-dev')),
    new BuiltinExtension('zip', array('zlib1g-dev')),
);

$PECL_EXTENSIONS = array(
       // install apcu before serializers so that they detect and enable support for it
       new PeclExtension('apcu', array(), array(), '5.1.14'),
       new PeclExtension('apcu_bc', array(), array(), '1.0.4', 'apc'),

       // install serializers to make them available for the rest of the extensions
       new PeclExtension('igbinary', array(), array(), '2.0.8'),
       new PeclExtension('msgpack', array(), array(), '2.0.2'),

       // install "regular" extensions
       new PeclExtension('grpc', array(), array(), '1.16.0'),
       new PeclExtension('imagick', array('libmagickwand-dev'), array(), '3.4.3', 'imagick', 'docker-php-ext-imagick.ini', array('ghostscript')),
       new PeclExtension('libsodium', array('libsodium-dev'), array(), '2.0.13', 'sodium', 'docker-php-ext-sodium.ini'),
       new PeclExtension('mailparse', array(), array(), '3.0.2'),
       new PeclExtension('memcached', array('libmemcached-dev', 'zlib1g-dev'), array('--enable-memcached-igbinary', '--enable-memcached-msgpack', '--enable-memcached-json'), '3.0.4'),
       new PeclExtension('oauth', array('libpcre3-dev'), array(), '2.0.3'),
       new PeclExtension('opencensus', array(), array(), '0.2.2'),
       new PeclExtension('protobuf', array(), array(), '3.6.1'),
       new PeclExtension('redis', array(), array('--enable-redis-igbinary', '--enable-redis-lzf'), '4.2.0'),
       new PeclExtension('yaml', array('libyaml-dev'), array(), '2.0.4'),
);

if ( version_compare( phpversion(), "7.2", ">=" ) ) {
       $PECL_EXTENSIONS[] = new PeclExtension('mcrypt', array('libmcrypt-dev'), array(), '1.0.1');
} else {
       $BUILTIN_EXTENSIONS[] = new BuiltinExtension('mcrypt', array('libmcrypt-dev'));
}

$dryRun = false;
if ( count($argv) == 2 && $argv[1] == '-n') {
	$dryRun = true;
}

install_extensions( $dryRun );
