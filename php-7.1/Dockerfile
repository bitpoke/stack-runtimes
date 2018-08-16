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

RUN exec >&2 \
    && echo "sendmail_path=/usr/sbin/ssmtp -t" | tee -a /usr/local/etc/php/conf.d/zz-01-defaults.ini \
    && echo "apc.serializer=igbinary" | tee -a /usr/local/etc/php/conf.d/zz-01-defaults.ini \
    && echo "session.serialize_handler=igbinary" | tee -a /usr/local/etc/php/conf.d/zz-01-defaults.ini

COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

RUN echo "<?php phpinfo(); " > /var/www/html/index.php

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]

CMD ["php", "-S", "0.0.0.0:3000", "-t", "/var/www/html"]
