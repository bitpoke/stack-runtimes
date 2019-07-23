ifndef __COMMON_MAKEFILE__

__COMMON_MAKEFILE__ := included

define print_target
  @$(call print_notice,Building $@...)
endef

define print_notice
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

define print_error
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

.build:
	mkdir -p "$@"

.build/tmp: | .build
	mkdir -p "$@"

.PHONY: clean
clean::
	rm -Rf .build


endif
