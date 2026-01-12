SHELL = /bin/sh
UE = C:\Program Files\Epic Games\UE_5.1
UAT = $(UE)\Engine\Build\BatchFiles\RunUAT.bat
UE_EDITOR = $(UE)\Engine\Binaries\Win64\UnrealEditor-Cmd.exe
WINDOWS_CURDIR := $(shell wslpath -w "$(CURDIR)/Unreal")
PROJECT := $(WINDOWS_CURDIR)\Pal.uproject
TURNKEY_ARGS = -command=VerifySdk -platform=Win64 -UpdateIfNeeded -project="$(PROJECT)"
BUILD_ARGS = -nop4 -utf8output -nocompileeditor -skipbuildeditor -cook -project="$(PROJECT)" \
						 -unrealexe="$(UE_EDITOR)" -platform=Win64 -installed -stage -archive -package -pak \
						 -compressed -prereqs -archivedirectory="$(WINDOWS_CURDIR)" -manifests \
						 -clientconfig=Shipping -nodebuginfo

.PHONY: build build_uat

build: Paks/UltrakillWingRemover_P.pak

build_uat:
	powershell.exe -Command '&"$(UAT)" -ScriptsForProject="$(PROJECT)" Turnkey $(TURNKEY_ARGS) BuildCookRun $(BUILD_ARGS) -nocompile -nocompileuat'

Unreal/Windows/Pal/Content/Paks/pakchunk8995-Windows.pak:
Unreal/Windows/Pal/Content/Paks/pakchunk8995-Windows.pak: build_uat

Paks:
	-mkdir Paks

Paks/UltrakillWingRemover_P.pak: Unreal/Windows/Pal/Content/Paks/pakchunk8995-Windows.pak Paks
	cp $< $@
