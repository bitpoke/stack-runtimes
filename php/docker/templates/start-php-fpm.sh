#! /bin/sh

SCRIPT_TAG="[start-php-fpm]"
NGINX_STOPPED_FILE="/tmp/pod/nginx-stopped"

interceptQuitSignal() {
  >&2 echo "$SCRIPT_TAG Waiting for nginx to stop."

  until [ -f $NGINX_STOPPED_FILE ]
    do sleep 0.1
  done

  >&2 echo "$SCRIPT_TAG Stopping php-fpm."

  # Send QUIT signal to subprocesses of this script (php-fpm master process in this case)
  PID=$$
  pkill --parent $PID --signal 3

  # Wait for the master subprocesses to end; should be good enough as long as they wait recursively
  while [ -n "$(pgrep --parent $PID)" ]; do sleep 0.1; done

  >&2 echo "$SCRIPT_TAG Stopped php-fpm."

  # Deactivate the trap.
  trap - QUIT
}

# Trap SIGQUIT signal to sleep until nginx has been stopped, before killing php-fpm
trap interceptQuitSignal QUIT

# Finally start php-fpm in background so that the trap may activate
/usr/local/sbin/php-fpm -y /usr/local/docker/etc/php-fpm.conf &

wait

sleep 0.2
