ifndef __PROJECT_MAKEFILE__

__PROJECT_MAKEFILE__ := included

REGISTRY ?= quay.io/presslabs


ifndef CI
TAG_SUFFIX ?= canary
endif

GIT_COMMIT = $(shell git describe --always --abbrev=40 --dirty)

endif
