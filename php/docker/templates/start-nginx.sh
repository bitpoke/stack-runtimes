#! /bin/sh

SCRIPT_TAG="[start-nginx]"
STOPPED_FILE="/tmp/pod/nginx-stopped"

>&2 echo "$SCRIPT_TAG Initiated start-nginx.sh script."

interceptQuitSignal() {
  >&2 echo "$SCRIPT_TAG Stopping nginx."

  # Send QUIT signal to subprocesses of this script (nginx master process in this case)
  PID=$$
  >&2 echo "$SCRIPT_TAG Killing subprocesses of process $PID."
  pkill --parent $PID --signal 3

  # Wait for the master subprocesses to end; should be good enough as long as they wait recursively
  while [ -n "$(pgrep --parent $PID)" ]; do sleep 0.1; done

  mkdir -p "$(dirname $STOPPED_FILE)" && touch $STOPPED_FILE

  >&2 echo "$SCRIPT_TAG Stopped nginx."

  # Deactivate the trap.
  trap - QUIT
}

# Cleanup stopped file in case of restart
rm -f $STOPPED_FILE

# Trap SIGQUIT signal to create the nginx-stopped file after shutting down
trap interceptQuitSignal QUIT

# Wait for php-fpm to get online
/usr/local/bin/dockerize -wait unix:///var/run/php-www.sock

# Finally start nginx in background so that the trap may activate
{{- if eq "debug" (default "warn" .Env.NGINX_ERROR_LOG_LEVEL) }}
/usr/bin/openresty-debug -p /var/lib/nginx -g 'daemon off;' -c /usr/local/docker/etc/nginx/nginx.conf &
{{- else }}
/usr/bin/openresty -p /var/lib/nginx -g 'daemon off;' -c /usr/local/docker/etc/nginx/nginx.conf &
{{- end }}

wait

sleep 0.2
