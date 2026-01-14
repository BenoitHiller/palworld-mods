SHELL = /bin/sh
STEAM_DIR ?= /mnt/c/Program Files (x86)/Steam
WORKSHOP_CONTENT_DIR ?= $(STEAM_DIR)/steamapps/workshop/content/1623730
SIMPLE_MODS = LongRangeFishing
COMPILED_MODS = UltrakillWingRemover SmallTerraprisma
MODS = $(SIMPLE_MODS) $(COMPILED_MODS)
MOD_TOOL = $(CURDIR)/scripts/build_mod.bash
OUT_DIR ?= $(CURDIR)/out
BUILD_DIR = $(CURDIR)/build
RUN_BAT = $(CURDIR)/scripts/run_bat.bash

UE = C:\Program Files\Epic Games\UE_5.1
UAT_PATH = $(UE)\Engine\Build\BatchFiles\RunUAT.bat
UE_EDITOR = $(UE)\Engine\Binaries\Win64\UnrealEditor-Cmd.exe
CURDIR_WIN := $(shell wslpath -w "$(CURDIR)")
UE_PROJECT_DIR = $(CURDIR_WIN)\$(MOD_NAME)\Unreal
UE_PROJECT = $(UE_PROJECT_DIR)\Pal.uproject

UE_TURNKEY_ARGS = -command=VerifySdk -platform=Win64 -UpdateIfNeeded -project="$(UE_PROJECT)"
UE_BUILD_ARGS = -nop4 -utf8output -nocompileeditor -skipbuildeditor -cook -project="$(UE_PROJECT)" \
		-unrealexe="$(UE_EDITOR)" -platform=Win64 -installed -stage -archive -package -pak \
		-compressed -prereqs -archivedirectory="$(UE_PROJECT_DIR)" -manifests \
		-clientconfig=Shipping -nodebuginfo -nocompile -nocompileuat

UAT_ARGS = -ScriptsForProject="$(UE_PROJECT)" \
	  Turnkey $(UE_TURNKEY_ARGS) \
		BuildCookRun $(UE_BUILD_ARGS)

UAT = $(RUN_BAT) "$(UAT_PATH)"

BUILD_PAK_FILE = $(MOD_NAME)/Unreal/Windows/Pal/Content/Paks/pakchunk$(CHUNK_ID)-Windows.pak

PAK_FILES = $(patsubst %,%/Paks/%_P.pak,$(COMPILED_MODS))

ifndef SKIP_UNREAL
BUILD_UNREAL = force
endif

export

###############
# Rules Start #
###############

.PHONY: $(MODS) force clean install build

build: $(MODS)
force:

install: DESTDIR = $(WORKSHOP_CONTENT_DIR)
install:
	$(MOD_TOOL) install_workshop $(MODS)

$(MODS):
	$(MOD_TOOL) package_workshop $@
	$(MOD_TOOL) package_nexus $@

$(PAK_FILES): $(BUILD_UNREAL)
	$(UAT) $(UAT_ARGS)
	-mkdir $(MOD_NAME)/Paks
	cp $(BUILD_PAK_FILE) $@

UltrakillWingRemover: MOD_NAME=UltrakillWingRemover
UltrakillWingRemover: CHUNK_ID=8995
UltrakillWingRemover: UltrakillWingRemover/Paks/UltrakillWingRemover_P.pak

SmallTerraprisma: MOD_NAME=SmallTerraprisma
SmallTerraprisma: CHUNK_ID=1096
SmallTerraprisma: SmallTerraprisma/Paks/SmallTerraprisma_P.pak

clean:
	-rm -r $(OUT_DIR)
