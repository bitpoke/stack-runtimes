SERIES := $(notdir $(shell find . -name 'php-*' -type d -maxdepth 1 -mindepth 1))

.PHONY: images
images: $(patsubst %,images-%,$(SERIES))

.PHONY: publish
publish: $(patsubst %,publish-%,$(SERIES))

images-%: %
	$(MAKE) -C $< images

publish-%: %
	$(MAKE) -C $< publish
