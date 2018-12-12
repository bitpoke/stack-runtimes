ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-stretch as slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PHP_VERSION=${PHP_VERSION}
ENV COMPOSER_VERSION=1.7.2
ENV SUPERVISORD_VERSION=0.5
ENV DOCKERIZE_VERSION=1.2.0

# compile su-exec
COPY docker/src/su-exec.c /usr/src/
RUN set -ex \
    && gcc -Wall -Werror -g -o /usr/local/bin/su-exec /usr/src/su-exec.c

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y gnupg2=2.1* \
    && curl -s https://openresty.org/package/pubkey.gpg | apt-key add - \
    && echo "deb http://openresty.org/package/debian stretch openresty" > /etc/apt/sources.list.d/openresty.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ssmtp=2.64* unzip=6.0* openresty=1.13* libyaml-dev=0.1* \
        less=481* git=1:2.11* openssh-client=1:7.4* \
    && rm -rf /var/lib/apt/lists/* \
    # install dockerize
    && curl -sL https://github.com/presslabs/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz -o dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    # install supervisord
    && curl -sL https://github.com/ochinchina/supervisord/releases/download/v${SUPERVISORD_VERSION}/supervisord_${SUPERVISORD_VERSION}_linux_amd64 -o /usr/local/bin/supervisord \
    && chmod +x /usr/local/bin/supervisord \
    # we need yaml support in install-extensions.php build script
    && pecl install yaml \
    && docker-php-ext-enable yaml \
    && chown -R www-data:www-data /var/www/html

COPY build-scripts /usr/local/build-scripts

RUN set -ex \
    # install composer
    && sh /usr/local/build-scripts/install-composer.sh \
    # install php extensions
    && apt-get update \
    && php /usr/local/build-scripts/install-extensions.php /usr/local/build-scripts/php-extensions.minimal.yaml \
    && rm -rf /var/lib/apt/lists/* \
    && sh /usr/local/build-scripts/cleanup.sh

# prepare rootfs
RUN set -ex \
    # symlink generated php.ini
    && ln -sf /usr/local/docker/etc/php.ini /usr/local/etc/php/conf.d/zz-01-custom.ini \
    # symlink php.ini from /var/run/secrets/presslabs.org/instance
    && ln -sf /var/run/secrets/presslabs.org/instance/php.ini /usr/local/etc/php/conf.d/zz-90-instance.ini \
    # our dummy index
    && { \
       echo "<?php phpinfo(); "; \
    } | tee /var/www/html/index.php >&2 \
    && chown -R www-data:www-data /var/www

COPY docker /usr/local/docker
EXPOSE 80
ENTRYPOINT ["/usr/local/docker/bin/docker-php-entrypoint"]
CMD ["supervisord", "-c", "/usr/local/docker/etc/supervisor.conf"]

FROM slim as full

RUN set -ex \
    # install php extensions
    && apt-get update \
    && php /usr/local/build-scripts/install-extensions.php \
    && rm -rf /var/lib/apt/lists/* \
    && sh /usr/local/build-scripts/cleanup.sh
