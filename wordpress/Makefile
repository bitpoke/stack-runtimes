DOCKERFILES = $(wildcard Dockerfile*)
SRCS := $(shell find docker -type f)
.PHONY: all
all: images

include ../project.Makefile
RUNTIME := wordpress-runtime
REGISTRY := $(REGISTRY)/$(RUNTIME)
include ../docker.Makefile

# Modify build targets for bedrock so that we build, test and publish bedrock and bedrock-build variants
.build/wordpress-runtime-bedrock-build: .build/wordpress-runtime-bedrock
.build/wordpress-runtime-bedrock-build: BASE_IMAGE := local.build/wordpress-runtime-bedrock
.build/wordpress-runtime-bedrock-build: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build: .build/tag-wordpress-runtime-bedrock

.build/test-wordpress-runtime-bedrock: .build/test-wordpress-runtime-bedrock-build ;

wordpress-runtime-bedrock: wordpress-runtime-bedrock-build
push-wordpress-runtime-bedrock: push-wordpress-runtime-bedrock-build

# Modify build targets for bedrock-php-8.0 so that we build, test and publish bedrock-php-8.0 and bedrock-build-php-8.0 variants
.build/wordpress-runtime-bedrock-build-php-8.0: .build/wordpress-runtime-bedrock-php-8.0
.build/wordpress-runtime-bedrock-build-php-8.0: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-8.0
.build/wordpress-runtime-bedrock-build-php-8.0: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build-php-8.0: .build/tag-wordpress-runtime-bedrock-php-8.0

.build/test-wordpress-runtime-bedrock-build-php-8.0: .build/test-wordpress-runtime-bedrock-build-php-8.0 ;

wordpress-runtime-bedrock-php-8.0: wordpress-runtime-bedrock-build-php-8.0
push-wordpress-runtime-bedrock-php-8.0: push-wordpress-runtime-bedrock-build-php-8.0
