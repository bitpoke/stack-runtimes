ARG BASE_IMAGE=quay.io/presslabs/php-runtime:7.3-latest
FROM ${BASE_IMAGE} as base

ENV WP_CLI_VERSION=2.1.0
USER root
COPY docker/build-scripts /usr/local/docker/build-scripts/
RUN set -ex \
    && /usr/local/docker/build-scripts/install-wp-cli
COPY --chown=www-data:www-data ./docker /usr/local/docker
USER www-data

###############################################################################

FROM base as static
WORKDIR /app/html
ARG WP_VERSION=latest
RUN set -ex \
    && wp core download --version=${WP_VERSION}
ONBUILD COPY --chown=www-data:www-data wp-config.php /app/html/wp-config.php
ONBUILD COPY --chown=www-data:www-data wp-content /app/html/wp-content

###############################################################################
