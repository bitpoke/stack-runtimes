include common.Makefile

REGISTRY ?= docker.io/bitpoke
PHP_VERSION ?= 7.4.27
WORDPRESS_VERSION ?= 5.8

ifndef CI
TAG_SUFFIX ?= canary
endif
BUILD_TAG ?= build

# The PHP series for which this version of WordPress builds the default tag, eg. docker.io/bitpoke/wordpress-runtime:5.2.2
WORDPRESS_PHP_SERIES := $(shell ./hack/wordpress-php-series $(WORDPRESS_VERSION))

# The PHP series for which to build the default bedrock tag
BEDROCK_PHP_SERIES := 7.4

GIT_COMMIT = $(shell git describe --always --abbrev=40 --dirty)

PHP_RUNTIME_REGISTRY := $(REGISTRY)/php-runtime
PHP_RUNTIME_SRCS := $(shell find php -type f)
PHP_SERIES ?= $(shell ./hack/php-series $(PHP_VERSION))
PHP_TAGS := $(PHP_SERIES) $(PHP_VERSION)

WORDPRESS_RUNTIME_REGISTRY := $(REGISTRY)/wordpress-runtime
WORDPRESS_RUNTIME_SRCS := $(shell find wordpress -type f)


ifeq ($(WORDPRESS_PHP_SERIES), $(PHP_SERIES))
WORDPRESS_TAGS := $(WORDPRESS_VERSION)
endif

ifeq ($(BEDROCK_PHP_SERIES), $(PHP_SERIES))
BEDROCK_TAGS := bedrock
BEDROCK_BUILD_TAGS := bedrock-build
endif

WORDPRESS_TAGS += $(patsubst %,$(WORDPRESS_VERSION)-php-%,$(PHP_TAGS))
BEDROCK_TAGS += $(patsubst %,bedrock-php-%,$(PHP_TAGS))
BEDROCK_BUILD_TAGS += $(patsubst %,bedrock-build-php-%,$(PHP_TAGS))

ifdef TAG_SUFFIX
WORDPRESS_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(WORDPRESS_TAGS))
BEDROCK_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(BEDROCK_TAGS))
BEDROCK_BUILD_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(BEDROCK_BUILD_TAGS))
PHP_TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(PHP_TAGS))
endif

.PHONY: images
images: php-runtime wordpress-runtime bedrock-runtime

.PHONY: push-php-images
push-php-images: php-runtime
	for tag in $(PHP_TAGS); do \
		docker push $(PHP_RUNTIME_REGISTRY):$${tag}; \
	done

.PHONY: push-wordpress-images
push-wordpress-images: wordpress-runtime
	for tag in $(WORDPRESS_TAGS); do \
		docker push $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
	done

.PHONY: push-bedrock-images
push-bedrock-images: bedrock-runtime
	for tag in $(BEDROCK_TAGS) $(BEDROCK_BUILD_TAGS); do \
		docker push $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
	done

.PHONY: pull-cache
pull-cache:
	docker pull $(PHP_RUNTIME_REGISTRY):$(PHP_SERIES) || true
	docker pull $(PHP_RUNTIME_REGISTRY):$(PHP_VERSION) || true
	docker pull $(PHP_RUNTIME_REGISTRY):$(lastword $(PHP_TAGS)) || true

.PHONY: test
test: .build/test/php .build/test/wordpress

.PHONY: php-runtime
php-runtime: .build/runtimes/php

.PHONY: wordpress-runtime
wordpress-runtime: .build/runtimes/wordpress

.PHONY: bedrock-runtime
bedrock-runtime: .build/runtimes/bedrock .build/runtimes/bedrock-build

.build/runtimes: | .build
	mkdir -p "$@"

.build/runtimes/php: .build/var/PHP_VERSION \
                     .build/var/PHP_SERIES \
                     .build/var/PHP_RUNTIME_REGISTRY \
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
	./hack/container-structure-test test --config php/tests/config.yaml --image local$<:$(BUILD_TAG)

.build/runtimes/wordpress: .build/var/WORDPRESS_VERSION \
                           .build/var/WORDPRESS_RUNTIME_REGISTRY \
                           .build/var/WORDPRESS_TAGS \
                           $(WORDPRESS_RUNTIME_SRCS) \
                           .build/runtimes/bedrock
	$(call print_target, $@)
	docker build \
		--build-arg WORDPRESS_VERSION=$(WORDPRESS_VERSION) \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--cache-from $(WORDPRESS_RUNTIME_REGISTRY):$(WORDPRESS_VERSION) \
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
	./hack/container-structure-test test --config wordpress/tests/structure-tests.yaml --image local$@:$(BUILD_TAG)
	TEST_IMAGE="local$@:$(BUILD_TAG)" ./hack/bats/bin/bats wordpress/tests/e2e.bats

.build/runtimes/bedrock: .build/var/WORDPRESS_RUNTIME_REGISTRY \
                         .build/var/BEDROCK_TAGS \
                         $(WORDPRESS_RUNTIME_SRCS) \
                         .build/runtimes/php
	$(call print_target, $@)
	docker build \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--cache-from $(WORDPRESS_RUNTIME_REGISTRY):bedrock-php-$(PHP_SERIES) \
		--tag local$@:$(BUILD_TAG) \
		--target bedrock \
		-f wordpress/Dockerfile wordpress
	set -e; \
		for tag in $(BEDROCK_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/runtimes/bedrock-build: .build/var/WORDPRESS_RUNTIME_REGISTRY \
                               .build/var/BEDROCK_BUILD_TAGS \
                               .build/runtimes/bedrock
	$(call print_target, $@)
	docker build \
		--build-arg BASE_IMAGE=local.build/runtimes/php:$(BUILD_TAG) \
		--cache-from $(WORDPRESS_RUNTIME_REGISTRY):bedrock-build-php-$(PHP_SERIES) \
		--tag local$@:$(BUILD_TAG) \
		--target bedrock-build \
		-f wordpress/Dockerfile wordpress
	set -e; \
		for tag in $(BEDROCK_BUILD_TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(WORDPRESS_RUNTIME_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/test/bedrock: .build/runtimes/bedrock
	docker build -t local$@:$(BUILD_TAG) \
		--build-arg RUNTIME_IMAGE=local$<:$(BUILD_TAG) \
		--build-arg BUILD_IMAGE=local$<-build:$(BUILD_TAG) \
		-f wordpress/tests/bedrock/Dockerfile wordpress/tests/bedrock
	./hack/container-structure-test test --config wordpress/tests/structure-tests.yaml --image local$@:$(BUILD_TAG)
	TEST_IMAGE="local$@:$(BUILD_TAG)" ./hack/bats/bin/bats wordpress/tests/e2e.bats

