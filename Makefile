REGISTRY := quay.io/presslabs
IMAGE_NAME := php-runtime
IMAGE_TAGS := canary
BUILD_TAG := build
GIT_COMMIT ?= $(shell git rev-parse HEAD)
CONTEXT_DIR ?= $(PWD)
build_args+= --build-arg PHP_VERSION=$(PHP_VERSION)

ifndef PHP_VERSION
$(error PHP_VERSION is not set)
endif

# Docker image targets
######################
.PHONY: images
images:
	docker build --pull \
		--build-arg VCS_REF=$(GIT_COMMIT) $(build_args) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(PHP_VERSION)-$(BUILD_TAG) \
		-f ./Dockerfile $(CONTEXT_DIR)
	set -e; \
		for tag in $(IMAGE_TAGS); do \
			docker tag $(REGISTRY)/$(IMAGE_NAME):$(PHP_VERSION)-$(BUILD_TAG) $(REGISTRY)/$(IMAGE_NAME):$(PHP_VERSION)-$${tag}; \
	done

.PHONY: publish
publish: images
	set -e; \
		for tag in $(IMAGE_TAGS); do \
		docker push $(REGISTRY)/$(IMAGE_NAME):$(PHP_VERSION)-$${tag}; \
	done

.PHONY: clean
clean:
	docker rmi $(REGISTRY)/$(IMAGE_NAME):$(PHP_VERSION)-$(BUILD_TAG)
