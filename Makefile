SHELL = /bin/sh
STEAM_DIR ?= /mnt/c/Program Files (x86)/Steam
WORKSHOP_CONTENT_DIR ?= $(STEAM_DIR)/steamapps/workshop/content/1623730
SIMPLE_MODS = LongRangeFishing
MODS = $(SIMPLE_MODS)
MOD_TOOL = $(CURDIR)/scripts/build_mod.bash
OUT_DIR ?= $(CURDIR)/out

export

###############
# Rules Start #
###############

.PHONY: $(MODS) clean install build mod build_mod

build: $(MODS)

install: DESTDIR = $(WORKSHOP_CONTENT_DIR)
install:
	$(MOD_TOOL) install_workshop $(MODS)

$(SIMPLE_MODS):
	$(MOD_TOOL) package_workshop $@

clean:
	-rm -r $(OUT_DIR)
