#!/bin/bash

quote_argument() {
  printf "%s" "'${1//\'/\'\'}'"
}

encode_argument() {
  local -r argument="$1"

  # encode once for passing to the powershell
  local encoded="$(quote_argument "$argument")"
  # then again for passing through to the script inside
  quote_argument "$encoded"
}

main() {
  local -r path="$1"
  shift

  local input="& $(quote_argument "$path")"

  for argument in "$@"; do
    input+=" $(quote_argument "$argument")"
  done


  powershell.exe -Command "$input"
}

main "$@"
