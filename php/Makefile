DOCKERFILES = $(wildcard Dockerfile*)
SRCS := $(shell find docker nginx-lua -type f)
.PHONY: all
all: images

include ../project.Makefile
RUNTIME := php-runtime
REGISTRY := $(REGISTRY)/$(RUNTIME)
include ../docker.Makefile
