ARG BUILDER_IMAGE
ARG RUNTIME_IMAGE
FROM ${BUILDER_IMAGE} as builder
FROM ${RUNTIME_IMAGE}
COPY --from=builder --chown=www-data:www-data /app /app
