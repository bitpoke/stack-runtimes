REGISTRY ?= quay.io/presslabs
PHP_VERSION ?= 7.3.7
WORDPRESS_VERSION ?= 5.2.2
BUILD_TAG ?= build
ifndef CI
TAG_SUFFIX ?= canary
endif

GIT_COMMIT ?= $(shell git describe --always --abbrev=40 --dirty)

PHP_RUNTIME_REGISTRY := $(REGISTRY)/php-runtime
PHP_RUNTIME_SRCS := $(shell find php -type f)
PHP_SERIES ?= $(shell ./hack/php-series $(PHP_VERSION))
PHP_TAGS := $(PHP_SERIES) $(PHP_VERSION)

WORDPRESS_RUNTIME_REGISTRY := $(REGISTRY)/wordpress-runtime
WORDPRESS_RUNTIME_SRCS := $(shell find wordpress -type f)
WORDPRESS_TAGS := $(WORDPRESS_VERSION) $(patsubst %,$(WORDPRESS_VERSION)-php-%,$(PHP_TAGS))
BEDROCK_TAGS := bedrock $(patsubst %,bedrock-php-%,$(PHP_TAGS))
BEDROCK_BUILD_TAGS := bedrock-build $(patsubst %,bedrock-build-php-%,$(PHP_TAGS))

ifdef TAG_SUFFIX
PHP_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(PHP_TAGS))
WORDPRESS_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(WORDPRESS_TAGS))
BEDROCK_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(BEDROCK_TAGS))
BEDROCK_BUILD_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(BEDROCK_BUILD_TAGS))
endif

IMAGE_NAME := php-runtime
IMAGE_TAGS := canary
BUILD_TAG := build
CONTEXT_DIR ?= $(PWD)
build_args+= --build-arg PHP_VERSION=$(PHP_VERSION)

define print_target
  @$(call print_notice,Building $@...)
endef

define print_notice
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

define print_error
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

.PHONY: images
images: php-runtime wordpress-runtime bedrock-runtime

.PHONY: push-images
push-images: images
	for tag in $(PHP_TAGS); do \
		docker push $(PHP_RUNTIME_REGISTRY):$${tag}; \
	done
	for tag in $(WORDPRESS_TAGS) $(BEDROCK_TAGS) $(BEDROCK_BUILD_TAGS); do \
		docker push $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
	done

.PHONY: pull-cache
pull-cache:
	docker pull $(PHP_RUNTIME_REGISTRY):$(PHP_SERIES) || true
	docker pull $(PHP_RUNTIME_REGISTRY):$(PHP_VERSION) || true
	docker pull $(PHP_RUNTIME_REGISTRY):$(lastword $(PHP_TAGS)) || true

.PHONY: test
test: .build/test/php .build/test/wordpress

.build/tmp: | .build
	mkdir -p "$@"

.PHONY: clean
clean::
	rm -Rf .build

.PHONY: php-runtime
php-runtime: .build/runtimes/php

.PHONY: wordpress-runtime
wordpress-runtime: .build/runtimes/wordpress

.PHONY: bedrock-runtime
bedrock-runtime: .build/runtimes/bedrock .build/runtimes/bedrock-build

include var.Makefile

.build/runtimes: | .build
	mkdir -p "$@"

.build/runtimes/php: .build/var/PHP_VERSION \
                     .build/var/PHP_SERIES \
                     .build/var/REGISTRY \
                     .build/var/PHP_TAGS \
                     $(PHP_RUNTIME_SRCS) \
                     | .build/runtimes
	$(call print_target, $@)
	docker build \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--cache-from $(PHP_RUNTIME_REGISTRY):$(PHP_SERIES) \
		--cache-from $(PHP_RUNTIME_REGISTRY):$(PHP_VERSION) \
		--cache-from $(PHP_RUNTIME_REGISTRY):$(lastword $(PHP_TAGS)) \
		--tag local$@:$(BUILD_TAG) \
		-f php/Dockerfile php
	set -e; \
		for tag in $(PHP_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(PHP_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/test/php: .build/runtimes/php
	./hack/container-structure-test test --config php/test/config.yaml --image local$<:$(BUILD_TAG)

.build/runtimes/wordpress: .build/var/WORDPRESS_VERSION \
                           .build/var/REGISTRY \
                           .build/var/WORDPRESS_TAGS \
                           .build/runtimes/php \
                           $(WORDPRESS_RUNTIME_SRCS)
	$(call print_target, $@)
	docker build \
		--build-arg WORDPRESS_VERSION=$(WORDPRESS_VERSION) \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--tag local$@:$(BUILD_TAG) \
		--target classic \
		-f wordpress/Dockerfile wordpress
	set -e; \
		for tag in $(WORDPRESS_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/test/wordpress: .build/runtimes/wordpress
	docker build -t local$@:$(BUILD_TAG) --build-arg BASE_IMAGE=local$<:$(BUILD_TAG) -f wordpress/tests/classic/Dockerfile wordpress/tests/classic

.build/runtimes/bedrock: .build/runtimes/php \
                         .build/var/REGISTRY \
                         $(WORDPRESS_RUNTIME_SRCS)
	$(call print_target, $@)
	docker build \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--tag local$@:$(BUILD_TAG) \
		--target bedrock \
		-f wordpress/Dockerfile wordpress
	set -e; \
		for tag in $(BEDROCK_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/runtimes/bedrock-build: .build/runtimes/bedrock
	$(call print_target, $@)
	docker build \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--tag local$@:$(BUILD_TAG) \
		--target bedrock-build \
		-f wordpress/Dockerfile wordpress
	set -e; \
		for tag in $(BEDROCK_BUILD_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"
