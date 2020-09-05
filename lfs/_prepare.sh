#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function prepare () {
  local COMMIT="$(git log -n 1 --format=oneline --abbrev-commit)"
  local BUILD_ID="$(date +'%y%m%d, %H%M%S')"
  BUILD_ID+=", '${COMMIT%% *}'"
  BUILD_ID+=", [==[${COMMIT#* }]==]"
  echo "Build ID: $BUILD_ID"

  local FWSRC="${INPUT_FIRMWARE_SRCDIR:-../.git/nodemcu-firmware-src-repo}"
  local SUB=
  for SUB in [a-z0-9]*/; do
    ( cat -- "$FWSRC"/lua_examples/lfs/dummy_strings.lua \
      && echo \
      && echo "return {$BUILD_ID}"
    ) >"$SUB/_buildID.lua" || return $?
  done
}


prepare "$@"; exit $?
