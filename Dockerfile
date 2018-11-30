ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ENV PHP_VERSION=${PHP_VERSION}
ENV COMPOSER_VERSION=1.7.2
ENV DOCKERIZE_VERSION=1.2.0
ENV SUPERVISORD_VERSION=0.5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY build-scripts /usr/local/build-scripts

RUN set -ex \
    # install dockerize
    && curl -L https://github.com/presslabs/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz -o dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    # install supervisord
    && curl -L https://github.com/ochinchina/supervisord/releases/download/v${SUPERVISORD_VERSION}/supervisord_${SUPERVISORD_VERSION}_linux_amd64 -o /usr/local/bin/supervisord \
    && chmod +x /usr/local/bin/supervisord

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y ssmtp=2.64* nginx-light=1.10* \
    && sh /usr/local/build-scripts/install-composer.sh \
    && php /usr/local/build-scripts/install-extensions.php \
    && rm -rf /var/lib/apt/lists/* \
    && sh /usr/local/build-scripts/cleanup.sh

RUN set -ex \
    # prepare rootfs
    && ln -sf /usr/local/docker/etc/php.ini /usr/local/etc/php/conf.d/zz-01-custom.ini \
    # our dummy index
    && { \
       echo "<?php phpinfo(); "; \
    } | tee /var/www/html/index.php >&2 \
    && chown -R www-data:www-data /var/www/html

COPY docker /usr/local/docker

EXPOSE 80
ENTRYPOINT ["/usr/local/docker/bin/docker-php-entrypoint"]
CMD ["supervisord", "-c", "/usr/local/docker/etc/supervisor.conf"]
