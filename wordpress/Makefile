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

# Modify build targets for bedrock-php-7.4 so that we build, test and publish bedrock-php-7.4 and bedrock-build-php-7.4 variants
.build/wordpress-runtime-bedrock-build-php-7.4: .build/wordpress-runtime-bedrock-php-7.4
.build/wordpress-runtime-bedrock-build-php-7.4: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-7.4
.build/wordpress-runtime-bedrock-build-php-7.4: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build-php-7.4: .build/tag-wordpress-runtime-bedrock-php-7.4

.build/test-wordpress-runtime-bedrock-build-php-7.4: .build/test-wordpress-runtime-bedrock-build-php-7.4 ;

wordpress-runtime-bedrock-php-7.4: wordpress-runtime-bedrock-build-php-7.4
push-wordpress-runtime-bedrock-php-7.4: push-wordpress-runtime-bedrock-build-php-7.4

# Modify build targets for bedrock-php-8.1 so that we build, test and publish bedrock-php-8.1 and bedrock-build-php-8.1 variants
.build/wordpress-runtime-bedrock-build-php-8.1: .build/wordpress-runtime-bedrock-php-8.1
.build/wordpress-runtime-bedrock-build-php-8.1: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-8.1
.build/wordpress-runtime-bedrock-build-php-8.1: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build-php-8.1: .build/tag-wordpress-runtime-bedrock-php-8.1

.build/test-wordpress-runtime-bedrock-build-php-8.1: .build/test-wordpress-runtime-bedrock-build-php-8.1 ;

wordpress-runtime-bedrock-php-8.1: wordpress-runtime-bedrock-build-php-8.1
push-wordpress-runtime-bedrock-php-8.1: push-wordpress-runtime-bedrock-build-php-8.1

# Modify build targets for bedrock-php-8.3 so that we build, test and publish bedrock-php-8.3 and bedrock-build-php-8.3 variants
.build/wordpress-runtime-bedrock-build-php-8.3: .build/wordpress-runtime-bedrock-php-8.3
.build/wordpress-runtime-bedrock-build-php-8.3: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-8.3
.build/wordpress-runtime-bedrock-build-php-8.3: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build-php-8.3: .build/tag-wordpress-runtime-bedrock-php-8.3

.build/test-wordpress-runtime-bedrock-build-php-8.3: .build/test-wordpress-runtime-bedrock-build-php-8.3 ;

wordpress-runtime-bedrock-php-8.3: wordpress-runtime-bedrock-build-php-8.3
push-wordpress-runtime-bedrock-php-8.3: push-wordpress-runtime-bedrock-build-php-8.3


