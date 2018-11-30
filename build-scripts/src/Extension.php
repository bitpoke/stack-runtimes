<?php
interface Extension {
	public function install( $dryRun = false );
	public function getName();
	public function getBuildDependencies();
	public function getExtraDependencies();
}

class BuiltinExtension implements Extension {
	private $name = "";
	private $buildDeps = array();
	private $configArgs = array();
	private $extraDeps = array();

	public function __construct( $name, $buildDeps = array(), $configArgs = array(), $extraDeps = array() ) {
		$this->name = $name;
		$this->buildDeps = $buildDeps;
		$this->configArgs = $configArgs;
		$this->extraDeps = $extraDeps;
	}

	public function getBuildDependencies() {
		return $this->buildDeps;
	}

	public function getExtraDependencies() {
		return $this->extraDeps;
	}

	public function getName() {
		return $this->name;
	}

	public function install( $dryRun = false ) {
		if ( count( $this->configArgs ) > 0 ) {
			$cmd = array('docker-php-ext-configure', $this->name);
			run(array_merge($cmd, $this->configArgs), $dryRun);	
		}
		$cmd = array('docker-php-ext-install', $this->name);
		run($cmd, $dryRun);	
	}
}

class PeclExtension implements Extension {
	private $name = "";
	private $extName = "";
	private $version = "";
	private $iniName = "";
	private $buildDeps = array();
	private $configArgs = array();
	private $extraDeps = array();

	public function __construct( $name, $buildDeps = array(), $configArgs = array(), $version="stable", $extName = "", $iniName = "", $extraDeps = array() ) {
		$this->name = $name;
		$this->extName = strlen( $extName ) > 0 ? $extName : $name;
		$this->iniName = strlen( $iniName ) > 0 ? $iniName : "docker-php-ext-$name.ini";
		$this->version = $version;
		$this->buildDeps = $buildDeps;
		$this->configArgs = $configArgs;
		$this->extraDeps = $extraDeps;
	}

	public function getBuildDependencies() {
		return $this->buildDeps;
	}

	public function getExtraDependencies() {
		return $this->extraDeps;
	}

	public function getName() {
		return $this->name;
	}

	private function getPeclTempDir() {
		return  pecl_temp_dir() . "/$this->name";
	}

	public function install( $dryRun = false ) {
		$cwd = getcwd();
		run(array('pecl', 'install', '--onlyreqdeps', '--nobuild', "{$this->name}-{$this->version}"), $dryRun);

		if ( ! $dryRun ) {
			$peclTmpDir = $this->getPeclTempDir($dryRun);
			if (chdir($peclTmpDir) === false) {
				log_msg("Cannot change dir to $peclTmpDir: ". error_get_last());
				exit(1);
			}
			log_msg("+ cd $peclTmpDir");
		} else {
			log_msg("+ cd /tmp/pear/temp/{$this->name}");
		}
		run(array('phpize'), $dryRun);

		run(array_merge(array('./configure'), $this->configArgs), $dryRun);	
		run(array('make', '-j', '4'), $dryRun);
		run(array('make', 'install'), $dryRun);
		run(array('docker-php-ext-enable', '--ini-name', $this->iniName, $this->extName), $dryRun);

		if (chdir($cwd) === false) {
			log_msg("Cannot change dir to $cwd: ". error_get_last());
			exit(1);
		}
	}
}
