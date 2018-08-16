<?php
function log_msg( $msg, $dest = STDERR ) {
	fwrite($dest, "$msg\n");
}

function run( $args, $dryRun = false, $passthru = true, &$lines = array() ) {
	$cmd = join(' ', array_map(escapeshellarg, $args));
	log_msg("+ $cmd");
	if ( !$dryRun ) {
		$last_line = "";
		if ( $passthru ) {
			passthru( $cmd, $return );
		} else {
			$last_line = exec( $cmd, $lines, $return );
		}
		if ( $return > 0 ) {
			if ( strlen($last_line) > 0 ) {
				log_msg($last_line);
			}
			exit( $return );
		}
		return $last_line;
	}
}

function pecl_temp_dir() {
	$baseDir = run(array('pecl', 'config-get', 'temp_dir'), false, false);
	return  rtrim( $baseDir, '/' );
}
