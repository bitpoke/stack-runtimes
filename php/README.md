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
* `SMTP_PASSWORD`
* `SMTP_PORT` (default to `587`)
* `SMTP_TLS` (default to `on`)
* `SMTP_STARTTLS` (default to `on`)
* `WORKER_GROUP` (default to `www-data`)
* `WORKER_USER` (default to `www-data`)
* `STACK_MEDIA_BUCKET` - if set serves the `STACK_MEDIA_PATH` from this media bucket
  (eg. gs://my-google-cloud-storage-bucket/prefix or s3://my-aws-s3-bucket)
* `STACK_MEDIA_PATH` (default to `/media`)
* `STACK_METRICS_ENABLED` (default to `false`)
* `STACK_METRICS_PORT` (default to `9145`)
* `STACK_METRICS_PHP_PATH` (default to `/metrics/php-fpm`)
* `STACK_METRICS_NGINX_PATH` (default to `/metrics/nginx`)
* `STACK_METRICS_WORDPRESS_PATH` (default to `/metrics/wordpress`)
* `STACK_PAGE_CACHE_ENABLED` (default to `false`) - toggles full page caching
* `STACK_PAGE_CACHE_BACKEND` - can be `redis`, `memcached` or `custom`
* `STACK_PAGE_CACHE_REDIS_HOST` (default to `localhost`)
* `STACK_PAGE_CACHE_REDIS_PORT` (default to `6379`)
* `STACK_PAGE_CACHE_MEMCACHED_HOST` (default to `127.0.0.1`)
* `STACK_PAGE_CACHE_MEMCACHED_PORT` (default to `11211`)
* `STACK_PAGE_CACHE_KEY_PREFIX` (default to `nginx-cache:`) - the prefix for the cache keys
* `STACK_PAGE_CACHE_KEY_UID` (default to `https$request_method$host$request_uri`) - the uniquely
  identifying part of a cache key (forms the cache key together with `STACK_PAGE_CACHE_KEY_PREFIX`)
* `STACK_PAGE_CACHE_DEBUG` (default to `false`) - toggles extra response headers for debugging
* `STACK_PAGE_CACHE_STORE_STATUSES` (default to `200 301 302`) - only responses with status codes
  included in this list are cached
* `STACK_PAGE_CACHE_RESPONSE_CACHE_CONTROL` (default to `on`) - corresponds to
  https://github.com/openresty/srcache-nginx-module#srcache_response_cache_control
* `STACK_PAGE_CACHE_EXPIRE_SECONDS` (default to `360`) - the default cache TTL when not specified
  otherwise in a response header (`cache-control` or `expires`)
* `STACK_PAGE_CACHE_KEY_INCLUDED_QUERY_PARAMS` - a list of query parameters separated by `,` which will be
  included in the cache key
* `STACK_PAGE_CACHE_KEY_DISCARDED_QUERY_PARAMS` - a list of query parameters separated by `,` which
  will not be included in the cache key (the request uri that reaches the backend remains unaltered);

Request query parameters that are not specified in `STACK_PAGE_CACHE_KEY_INCLUDED_QUERY_PARAMS` 
or `STACK_PAGE_CACHE_KEY_DISCARDED_QUERY_PARAMS` will result in a cache skip.

## OpenResty modules
Lua modules found in `/php/nginx-lua` are installed via [opm](https://opm.openresty.org) using the `--cwd` option.
