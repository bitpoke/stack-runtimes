<?php
require_once dirname( __FILE__ ) . '/src/autoload.php';

$dryRun = false;
if ( count($argv) == 2 && $argv[1] == '-n') {
	$dryRun = true;
}

install_extensions( $dryRun );
