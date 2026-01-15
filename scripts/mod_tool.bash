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
declare PALSCHEMA_PREFIX=Pal/Binaries/Win64/ue4ss/Mods/PalSchema/mods
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

target_files() {
  local -r info_file="$1"

  jq -r '
    .["InstallRule"][]["Targets"] | flatten | @tsv
  ' "$info_file"

  jq -r '.["Thumbnail"]' "$INFO_FILE"

  echo "Info.json"
}

package_workshop() {
  local MOD_OUT_DIR="$OUT_DIR/workshop/$WORKSHOP_ID"
  local thumbnail="$(jq -r '.["Thumbnail"]' "$INFO_FILE")"

  mkdir -p "$MOD_OUT_DIR" || true
  debug "Packaging %s into %s" "$MOD_NAME" "$MOD_OUT_DIR"

  rsync -arvh --delete --files-from=<(target_files "$INFO_FILE") "$MOD_FOLDER/" "$MOD_OUT_DIR/"
}

package_nexus() {
  local MOD_BUILD_DIR="$BUILD_DIR/nexus/$MOD_NAME"
  local MOD_STEAM_FOLDER="$OUT_DIR/workshop/$WORKSHOP_ID"
  local PALSCHEMA_BUILD_DIR="$MOD_BUILD_DIR/$PALSCHEMA_PREFIX/$MOD_NAME"
  local PAKS_BUILD_DIR="$MOD_BUILD_DIR/$PAKS_PREFIX"
  local version="$(jq -r '.["Version"]' "$INFO_FILE")"

  mkdir -p "$MOD_BUILD_DIR" || true
  debug "Packaging %s into %s" "$MOD_NAME" "$MOD_OUT_DIR"

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

initialize() {
  WORK_DIR="${WORK_DIR-$PWD}"
  OUT_DIR="${OUT_DIR-$WORK_DIR/out}"
  BUILD_DIR="$WORK_DIR/build"
}

load_config() {
  MOD_NAME="$1"

  MOD_FOLDER="$WORK_DIR/$MOD_NAME"
  INFO_FILE="$MOD_FOLDER/Info.json"
  WORKSHOP_FILE="$MOD_FOLDER/.workshop.json"

  WORKSHOP_ID="$(jq -r '.["publishedfileid"]' "$WORKSHOP_FILE")"
  WORKSHOP_OUT_DIR="$OUT_DIR/workshop/$WORKSHOP_ID"
}

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
