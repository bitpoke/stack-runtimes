ARG BASE_IMAGE=quay.io/presslabs/php-runtime:7.3-latest
FROM ${BASE_IMAGE} as base

ENV WP_CLI_VERSION=2.2.0
ENV WP_CLI_CONFIG_PATH=/app/wp-cli.yml
USER root
COPY docker/build-scripts /usr/local/docker/build-scripts/
RUN set -ex \
    && /usr/local/docker/build-scripts/install-wp-cli \
    && rm -rf /app \
    && mkdir /app /src \
    && chown -R www-data:www-data /app /src

COPY --chown=www-data:www-data ./docker /usr/local/docker
USER www-data

###############################################################################

FROM base as bedrock
ENV DOCUMENT_ROOT=/app/web
ENV MEDIA_BUCKET_PATH=/app/uploads
RUN set -ex \
    && { \
       echo "path: $DOCUMENT_ROOT/wp"; \
    } | tee /app/wp-cli.yml >&2

###############################################################################

FROM bedrock as bedrock-build

WORKDIR /src
# Install project dependencies as first build step for child images so that we
# heat up composer cache
ONBUILD COPY --chown=www-data:www-data composer.json composer.lock /src/
ONBUILD RUN composer install --no-dev --no-interaction --no-progress --no-ansi --no-scripts

ONBUILD COPY --chown=www-data:www-data . /src
ONBUILD RUN composer install --no-dev --no-interaction --no-progress --no-ansi --no-scripts
ONBUILD RUN cp -a /src/. /app

###############################################################################

FROM base as classic
ARG WORDPRESS_VERSION=latest
ENV MEDIA_BUCKET_PATH=/wp-content/uploads
RUN set -ex \
    && { \
       echo "path: $DOCUMENT_ROOT"; \
    } | tee /app/wp-cli.yml >&2 \
    && wp core download --path=html --version=${WORDPRESS_VERSION}
ONBUILD COPY --chown=www-data:www-data wp-config.php /app/html/wp-config.php
ONBUILD COPY --chown=www-data:www-data wp-content /app/html/wp-content
