ARG RUNTIME_IMAGE=local.build/runtimes/bedrock:build
ARG BUILD_IMAGE=local.build/runtimes/bedrock-build:build
FROM ${BUILD_IMAGE} as builder
FROM ${RUNTIME_IMAGE}
COPY --from=builder --chown=www-data:www-data /app /app
