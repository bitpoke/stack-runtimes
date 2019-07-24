DOCKERFILES = $(wildcard Dockerfile*)
SRCS := $(shell find docker -type f)
.PHONY: all
all: images

include ../project.Makefile
RUNTIME := wordpress-runtime
REGISTRY := $(REGISTRY)/$(RUNTIME)
include ../docker.Makefile
