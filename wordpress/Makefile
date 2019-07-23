.PHONY: images
images: .build/wordpress-runtime

.PHONY: test
test: .build/wordpress-runtime-test

include ../project.Makefile

WORDPRESS_VERSION ?= 5.2.2
PHP_VERSION ?= 7.3.7
PHP_SERIES ?= $(shell ../hack/php-series $(PHP_VERSION))
SRCS := $(shell find Dockerfile docker -type f)

IMAGE_REGISTRY := $(REGISTRY)/wordpress-runtime
TAGS := $(WORDPRESS_VERSION)-php-$(PHP_SERIES) $(WORDPRESS_VERSION)-php-$(PHP_VERSION)
ifdef TAG_SUFFIX
TAGS := $(patsubst %,%-$(TAG_SUFFIX),$(TAGS))
endif

BASE_IMAGE ?= $(REGISTRY)/php-runtime:$(PHP_VERSION)

CACHE_IMAGES += $(BASE_IMAGE)
CACHE_IMAGES += $(patsubst %,$(IMAGE_REGISTRY):%,$(TAGS))
CACHE_IMAGES_DIGESTS := $(shell for i in $(CACHE_IMAGES) ; do docker images -q $${i}; done)

include ../var.Makefile
include ../common.Makefile

.PHONY: pull-cache
pull-cache: .build/var/CACHE_IMAGES
	for image in $(CACHE_IMAGES) ; do \
		docker pull $${image} || true ; \
	done

.PHONY: push-images
push-images: images
	for tag in $(TAGS); do \
		docker push $(IMAGE_REGISTRY):$${tag}; \
	done


.build/wordpress-runtime: .build/var/PHP_VERSION \
                          .build/var/PHP_SERIES \
                          .build/var/BASE_IMAGE \
                          .build/var/TAGS \
                          .build/var/CACHE_IMAGES_DIGESTS \
                          $(SRCS) \
                          | .build
	$(call print_target, $@)
	docker build --pull -t local$@:$(BUILD_TAG) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		$(patsubst %,--cache-from=%,$(CACHE_IMAGES)) \
	.
	set -e; \
		for tag in $(TAGS); do \
			docker tag local$@:$(BUILD_TAG) $(IMAGE_REGISTRY):$${tag}; \
		done
	@touch "$@"

.build/wordpress-runtime-test: .build/wordpress-runtime
	../hack/container-structure-test test --config php/tests/config.yaml --image local$<:$(BUILD_TAG)
