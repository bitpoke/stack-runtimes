# php-runtime
PHP docker images with batteries included for running WordPress

## Environment variables
* `PORT` (default to `8080`) - the port your app
* `DOCUMENT_ROOT` (default to `/app/html`)
* `MAX_BODY_SIZE` (default to `10`) - the size in megabytes for the maximum
  client request body size.  (this controls nginx `client_max_body_size` and
  php
  `upload_max_filesize` and `post_max_size`)
* `NGINX_ACCESS_LOG` (default to `off`) - where to write nginx's access log
* `NGINX_ERROR_LOG` (default to `/dev/stderr`) - where to write nginx's error
  log
* `NGINX_STATUS_PATH` (default to `/-/nginx-status`) - where to expose nginx's
  status
* `PHP_ACCESS_LOG_FORMAT` (default to `%R - %u %t \"%m %r\" %s`) - see
  http://php.net/manual/ro/install.fpm.configuration.php for more options
* `PHP_ACCESS_LOG` (default to `/var/log/stdout`) - where to write php's
  access log. Can be set to `off` to disable it entirely.
* `PHP_LIMIT_EXTENSIONS` (default to `.php`) - space separated list of file
  extensions for which to allow execution of php code
* `PHP_MAX_CHILDREN` (default to `5`)
* `PHP_MAX_REQUESTS` (default to `500`)
* `PHP_MAX_SPARE_SERVERS` (default to `PHP_MAX_CHILDREN / 2 + 1`)
* `PHP_MIN_SPARE_SERVERS` (default to `PHP_MAX_CHILDREN / 3`)
* `PHP_START_SERVERS` (default to `(PHP_MAX_SPARE_SERVERS - PHP_MIN_SPARE_SERVERS) / 2 + PHP_MIN_SPARE_SERVERS`)
* `PHP_MEMORY_LIMIT` (default to `128`). PHP request memory limit in megabytes
* `PHP_PING_PATH` (default to `/-/php-ping`)
* `PHP_PM` (default to `dynamic`) - can be set to `dynamic`, `static`,
  `ondemand`
* `PHP_PROCESS_IDLE_TIMEOUT` (default to `10`) - time in seconds to wait until
  killing an idle worker (used only when `PHP_PM` is set to `ondemand`)
* `PHP_REQUEST_TIMEOUT` (default to `30`) - Time in seconds for serving a
  single request. PHP `max_execution_time` is set to this value and can only
  be set to a lower value. If set to a higher one, the request will still be
  killed after this timeout.
* `PHP_SLOW_REQUEST_TIMEOUT` (default to `0`) - Time in seconds after which a
  request is logged as slow. Set to `0` to disable slow logging.
* `PHP_STATUS_PATH` (default to `/-/php-status`)
* `PHP_WORKER_CLEAR_ENV` (default to `no`) - whenever to clear the env for php
  workers
* `SERVER_NAME` (default to `_`)
* `SMTP_HOST` (default to `localhost`)
* `SMTP_USER`
* `SMTP_PASS`
* `SMTP_PORT` (default to `587`)
* `SMTP_TLS` (default to `yes`)
* `WORKER_GROUP` (default to `www-data`)
* `WORKER_USER` (default to `www-data`)
* `STACK_MEDIA_BUCKET` - if set serves the `STACK_MEDIA_PATH` from this media bucket
  (eg. gs://my-google-cloud-storage-bucket/prefix or s3://my-aws-s3-bucket)
* `STACK_MEDIA_PATH` (default to `/media`)
