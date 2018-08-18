ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ENV PHP_SERIES=7.1
ENV PHP_VERSION=${PHP_VERSION}
ENV COMPOSER_VERSION=1.7.2

COPY build-scripts /usr/local/build-scripts

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y ssmtp=2.64* \
    && sh /usr/local/build-scripts/install-composer.sh \
    && php /usr/local/build-scripts/install-extensions.php \
    && rm -rf /var/lib/apt/lists/* \
    && sh /usr/local/build-scripts/cleanup.sh

ENV DOCKERIZE_VERSION=0.6.1
RUN set -ex \
    # install dockerize and wrap php-fpm to start with dockerize tailing /var/log/stderr and /var/log/stdout
    && curl -L https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz -o dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && mkfifo /var/log/stderr \
    && mkfifo /var/log/stdout \
    && chown www-data:www-data /var/log/stdout \
    && chown www-data:www-data /var/log/stderr \
    && mv /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm.orig \
    && { \
        echo '#!/bin/sh'; \
        echo 'exec dockerize -stderr /var/log/stderr -stdout /var/log/stdout -poll /usr/local/sbin/php-fpm.orig -d"error_log=/var/log/stderr" -d"opcache.error_log=/var/log/stderr" -d"log_errors=on" -d"display_errors=off" "$@"'; \
        } | tee /usr/local/sbin/php-fpm >/dev/null \
    && chmod +x /usr/local/sbin/php-fpm \
    && { \
        echo '[global]'; \
        echo 'error_log = /var/log/stderr'; \
        echo; \
        echo '[www]'; \
        echo 'catch_workers_output = yes'; \
        echo 'access.log = /var/log/stdout'; \
        } | tee /usr/local/etc/php-fpm.d/zz-dockerized.conf >/dev/null

RUN { \
        echo 'sendmail_path=/usr/sbin/ssmtp -t'; \
        echo 'apc.serializer=igbinary'; \
        echo 'session.serialize_handler=igbinary'; \
    } | tee /usr/local/etc/php/conf.d/zz-01-defaults.ini >&2 \
    && { \
       echo "<?php phpinfo(); "; \
    } | tee /var/www/html/index.php >&2 \
    && chown -R www-data:www-data /var/www/html

COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]
CMD ["php-fpm"]
