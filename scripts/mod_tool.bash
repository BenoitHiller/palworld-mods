#!/bin/bash

set -ef

declare MOD_NAME
declare WORK_DIR
declare OUT_DIR
declare MOD_FOLDER
declare INFO_FILE
declare WORKSHOP_FILE
declare WORKSHOP_ID
declare WORKSHOP_OUT_DIR
declare UE4SS_PREFIX=Pal/Binaries/Win64/ue4ss/Mods
declare PALSCHEMA_PREFIX="$UE4SS_PREFIX/PalSchema/mods"
declare PAKS_PREFIX="Pal/Content/Paks/~mods"

debug() {
  printf "$@" >&2
  printf "\n" >&2
}

error() {
  debug "$@"
  return 1
}

ensure_dir() {
  mkdir -p "$@" 2>/dev/null || true
}

clean_dir() {
  rm -r "$@" 2>/dev/null || true
}

# Build the list of files and folders that need to be copied over into the Steam Workshop folder
#
# 1.info_file the path to the Info.json file for the mod
target_files() {
  local -r info_file="$1"

  jq -r '
    .["InstallRule"][]["Targets"] | flatten | @tsv
  ' "$info_file"

  jq -r '.["Thumbnail"]' "$INFO_FILE"

  echo "Info.json"
}

# Copy all of the files identified by target_files() into a folder within the OUT_DIR based on the id of this mod
#
# Pulls all arguments from the variables configured by load_config()
package_workshop() {
  local MOD_OUT_DIR="$OUT_DIR/workshop/$WORKSHOP_ID"
  local thumbnail="$(jq -r '.["Thumbnail"]' "$INFO_FILE")"

  mkdir -p "$MOD_OUT_DIR" || true
  debug "Packaging %s into %s" "$MOD_NAME" "$MOD_OUT_DIR"

  rsync -arvh --delete --files-from=<(target_files "$INFO_FILE") "$MOD_FOLDER/" "$MOD_OUT_DIR/"
}

# Create a vortex compatible zip archive of this mod
#
# Note that this currently only places PalSchema and Pak files
#
# Pulls all arguments from the variables configured by load_config()
package_nexus() {
  local MOD_BUILD_DIR="$BUILD_DIR/nexus/$MOD_NAME"
  local MOD_STEAM_FOLDER="$OUT_DIR/workshop/$WORKSHOP_ID"
  local PALSCHEMA_BUILD_DIR="$MOD_BUILD_DIR/$PALSCHEMA_PREFIX/$MOD_NAME"
  local UE4SS_BUILD_DIR="$MOD_BUILD_DIR/$UE4SS_PREFIX/$MOD_NAME/Scripts"
  local PAKS_BUILD_DIR="$MOD_BUILD_DIR/$PAKS_PREFIX"
  local version="$(jq -r '.["Version"]' "$INFO_FILE")"

  mkdir -p "$MOD_BUILD_DIR" || true
  debug "Packaging %s into %s" "$MOD_NAME" "$MOD_OUT_DIR"

  if [[ -d "$MOD_STEAM_FOLDER/Scripts" ]]; then
    ensure_dir "$UE4SS_BUILD_DIR"
    rsync -arvh --delete "$MOD_STEAM_FOLDER/Scripts" "$UE4SS_BUILD_DIR"
  else
    clean_dir "$PALSCHEMA_BUILD_DIR"
  fi

  if [[ -d "$MOD_STEAM_FOLDER/PalSchema" ]]; then
    ensure_dir "$PALSCHEMA_BUILD_DIR"
    rsync -arvh --delete "$MOD_STEAM_FOLDER/PalSchema/" "$PALSCHEMA_BUILD_DIR/"
  else
    clean_dir "$PALSCHEMA_BUILD_DIR"
  fi

  if [[ -d "$MOD_STEAM_FOLDER/Paks" ]]; then
    ensure_dir "$PAKS_BUILD_DIR"
    rsync -arvh --delete "$MOD_STEAM_FOLDER/Paks/" "$PAKS_BUILD_DIR/"
  else
    clean_dir "$PAKS_BUILD_DIR"
  fi

  ensure_dir "$OUT_DIR/nexus"

  (
    cd "$MOD_BUILD_DIR"
    set +f
    zip -FS -r "$OUT_DIR/nexus/$MOD_NAME-$version.zip" ./*
  )
}

# Copy the folder produced by package_workshop() into the workshop folder where Steam can find them
#
# @. The mods you want to copy as individual arguments
install_workshop() {
  if [[ -z "$DESTDIR" ]]; then
    error "DESTDIR was not set, unable to perform install"
  fi

  debug "Installing mods to %s" "$DESTDIR"

  for mod in "$@"; do
    load_config "$mod"

    if [[ -d "$WORKSHOP_OUT_DIR" ]]; then
      rsync -avh --delete --exclude=".workshop.json" "$WORKSHOP_OUT_DIR" "$DESTDIR/"
    else
      error "No workshop files found at %s, install skipped." "$WORKSHOP_OUT_DIR"
    fi
  done
}

# Configure the global variables for things that are the same for all mods
#
# WORK_DIR: expected to be the root of the git repository. Will take its value from ENV if you specify it there.
# OUT_DIR: where to place the final folders (not the install location. Will take its value from ENV if you specify it there.
# BUILD_DIR: where to place intermediary files.
initialize() {
  WORK_DIR="${WORK_DIR-$PWD}"
  OUT_DIR="${OUT_DIR-$WORK_DIR/out}"
  BUILD_DIR="$WORK_DIR/build"
}

# Populate global variables used by individual mods
#
# 1.MOD_NAME the mod to load configuration for
#
# Configured Variables:
#
# MOD_FOLDER: where the source for this mod is located
# INFO_FILE: the Info.json file for the mod. Contains most metadata.
# WORKSHOP_FILE: the .workshop.json file, which is more like a cache maintained by the uploader. Only really has the workshop id in it.
# WORKSHOP_ID: the id of the workshop mod on Steam.
# WORKSHOP_OUT_DIR: where to place the final folder for this mod.
load_config() {
  MOD_NAME="$1"

  MOD_FOLDER="$WORK_DIR/$MOD_NAME"
  INFO_FILE="$MOD_FOLDER/Info.json"
  WORKSHOP_FILE="$MOD_FOLDER/.workshop.json"

  WORKSHOP_ID="$(jq -r '.["publishedfileid"]' "$WORKSHOP_FILE")"
  WORKSHOP_OUT_DIR="$OUT_DIR/workshop/$WORKSHOP_ID"
}

# This is a tool to help with gathering the files for a mod and packaging them
# as needed for the different platforms.
#
# What folders go where is defined within a json file so was just a bit to
# frustrating to get make to handle directly, at least at the start. I will
# hopefully be able to roll more of this into the Makefile directly in the
# future so that I can take advantage of it checking whether it needs to
# rebuild things.
main() {
  local -r command_name="$1"

  initialize

  case "$command_name" in
    package_workshop)
      load_config "$2"
      package_workshop
      ;;
    package_nexus)
      load_config "$2"
      package_nexus
      ;;
    install_workshop)
      shift
      install_workshop "$@"
      ;;
    get_id)
      load_config "$2"
      echo "$WORKSHOP_ID"
      ;;
  esac
}

main "$@"
