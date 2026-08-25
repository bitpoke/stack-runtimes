ifndef __DOCKER_MAKEFILE__

__DOCKER_MAKEFILE__ := included

makefile_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
include $(makefile_dir)/common.Makefile
include $(makefile_dir)/var.Makefile

# this dance is required since .build/var/VARNAME requires that VARNAME to be defined
# and TAG_SUFFIX is not always defined
ifdef TAG_SUFFIX
TAG_SUFFIX_SLUG := -$(TAG_SUFFIX)
TAG_SUFFIX_DEP := .build/var/TAG_SUFFIX
else
TAG_SUFFIX_DEP := .build/.TAG_SUFFIX
.build/.TAG_SUFFIX: | .build
	@rm -f .build/var/TAG_SUFFIX
endif
.PRECIOUS: .build/var/TAG_SUFFIX

define build_targets_for
$(patsubst Dockerfile-%,$(1)-%,$(DOCKERFILES))
endef

DOCKER_BUILD ?= docker build --pull

.PHONY: images
$(call build_targets_for, $(RUNTIME)):
images: $(call build_targets_for, $(RUNTIME))
$(RUNTIME)-%: .build/$(RUNTIME)-% ;

.PHONY: test
$(call build_targets_for, test-$(RUNTIME)):
test: $(call build_targets_for, test-$(RUNTIME))
test-$(RUNTIME)-%: .build/test-$(RUNTIME)-% ;

.PHONY: pull-cache
$(call build_targets_for, pull-$(RUNTIME)):
pull-cache: $(call build_targets_for, pull-$(RUNTIME))
pull-$(RUNTIME)-%:
	docker pull $(REGISTRY):$(@:pull-$(RUNTIME)-%=%)$(TAG_SUFFIX_SLUG) || true

.PHONY: tags
$(call build_targets_for, tag-$(RUNTIME)):
tags: $(call build_targets_for, tag-$(RUNTIME))
tag-$(RUNTIME)-%: .build/tag-$(RUNTIME)-% ;

.PHONY: push-images
$(call build_targets_for, push-$(RUNTIME)):
push-images: $(call build_targets_for, push-$(RUNTIME))
push-$(RUNTIME)-%: .build/tag-$(RUNTIME)-%
	@for tag in $$(cat $<); do \
		echo docker push $(REGISTRY):$${tag} ; \
		docker push $(REGISTRY):$${tag} ; \
	done

.PRECIOUS: .build/$(RUNTIME)-%
.build/$(RUNTIME)-%: Dockerfile-% $(SRCS) | .build
	$(DOCKER_BUILD) \
		$(patsubst %,--build-arg BASE_IMAGE=%,$(BASE_IMAGE)) \
		$(patsubst %,--build-arg PHP_BASE_IMAGE=%,$(PHP_BASE_IMAGE)) \
		--build-arg COMPOSER_AUTH= \
		-t local$@ \
		--cache-from $(REGISTRY):$(@:.build/$(RUNTIME)-%=%) \
		--cache-from $(REGISTRY):$(@:.build/$(RUNTIME)-%=%)$(TAG_SUFFIX_SLUG) \
		-f $(@:.build/$(RUNTIME)-%=Dockerfile-%) .
	touch "$@"

.build/test-$(RUNTIME)-%: .build/$(RUNTIME)-%
	$(CURDIR)/test/test.sh local$<

.PRECIOUS: .build/tag-$(RUNTIME)-%
.build/tag-$(RUNTIME)-%: .build/$(RUNTIME)-% $(TAG_SUFFIX_DEP)
	@TAG_SUFFIX="$(TAG_SUFFIX)" ./tag.sh $(@:.build/tag-$(RUNTIME)-%=%) local$(@:.build/tag-$(RUNTIME)-%=.build/$(RUNTIME)-%) | sort | uniq > $@
	@for tag in $$(cat $@); do \
		echo docker tag local$(@:.build/tag-$(RUNTIME)-%=.build/$(RUNTIME)-%) $(REGISTRY):$${tag} ; \
		docker tag local$(@:.build/tag-$(RUNTIME)-%=.build/$(RUNTIME)-%) $(REGISTRY):$${tag} ; \
	done

endif
