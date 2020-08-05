DOCKERFILES = $(wildcard Dockerfile*)
SRCS := $(shell find docker -type f)
.PHONY: all
all: images

include ../project.Makefile
RUNTIME := wordpress-runtime
REGISTRY := $(REGISTRY)/$(RUNTIME)
include ../docker.Makefile

.build/wordpress-runtime-5.2: .build/wordpress-runtime-bedrock
.build/wordpress-runtime-5.2: BASE_IMAGE := local.build/wordpress-runtime-bedrock
.build/wordpress-runtime-5.2: DOCKER_BUILD := docker build

.build/wordpress-runtime-5.1: .build/wordpress-runtime-bedrock-php-7.2
.build/wordpress-runtime-5.1: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-7.2
.build/wordpress-runtime-5.1: DOCKER_BUILD := docker build

# Modify build targets for bedrock so that we build, test and publish bedrock and bedrock-build variants
.build/wordpress-runtime-bedrock-build: .build/wordpress-runtime-bedrock
.build/wordpress-runtime-bedrock-build: BASE_IMAGE := local.build/wordpress-runtime-bedrock
.build/wordpress-runtime-bedrock-build: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build: .build/tag-wordpress-runtime-bedrock

.build/test-wordpress-runtime-bedrock: .build/test-wordpress-runtime-bedrock-build ;

wordpress-runtime-bedrock: wordpress-runtime-bedrock-build
push-wordpress-runtime-bedrock: push-wordpress-runtime-bedrock-build

# Modify build targets for bedrock-php-7.2 so that we build, test and publish bedrock-php-7.2 and bedrock-build-php-7.2 variants
.build/wordpress-runtime-bedrock-build-php-7.2: .build/wordpress-runtime-bedrock-php-7.2
.build/wordpress-runtime-bedrock-build-php-7.2: BASE_IMAGE := local.build/wordpress-runtime-bedrock-php-7.2
.build/wordpress-runtime-bedrock-build-php-7.2: DOCKER_BUILD := docker build

.build/tag-wordpress-runtime-bedrock-build-php-7.2: .build/tag-wordpress-runtime-bedrock-php-7.2

.build/test-wordpress-runtime-bedrock-build-php-7.2: .build/test-wordpress-runtime-bedrock-build-php-7.2 ;

wordpress-runtime-bedrock-php-7.2: wordpress-runtime-bedrock-build-php-7.2
push-wordpress-runtime-bedrock-php-7.2: push-wordpress-runtime-bedrock-build-php-7.2

# Modify build targets for bedrock-php-7.3 so that we build, test and publish bedrock-php-7.3 and bedrock-build-php-7.3 variants
.build/wordpress-runtime-bedrock-php-7.3: .build/wordpress-runtime-bedrock-build-php-7.3
