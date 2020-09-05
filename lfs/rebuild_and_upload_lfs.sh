#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function rebuild_and_upload_lfs () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  [ -x "../$FUNCNAME.sh" ] || return 3$(
    echo "E: This script is meant to be run in an lfs/ subdirectory." >&2)
  pushd .. >/dev/null || return $?
  local FWSRC='../.git/nodemcu-firmware-src-repo'
  [ -f "$FWSRC"/Makefile ] || return 3$(
    echo "E: Please make $FWSRC a symlink to your firmware source repo." >&2)
  INPUT_FIRMWARE_SRCDIR="$FWSRC" ./_prepare.sh || return $?
  popd >/dev/null || return $?
  local BFN="$(basename -- "$PWD")"
  local LFS="../$BFN.lfs"
  luac-for-nodemcu -f -o "$LFS" -- *.lua || return $?

  local MAX=0 SIZE="$(stat -c %s -- "$LFS")"
  [ -n "$SIZE" ] || return 3$(echo "E: unable to measure the LFS size" >&2)
  let MAX="${MAXLFS_KB:-64} * 1024"
  [ "$SIZE" -le "$MAX" ] || return 3$(
    echo "E: LFS too big: $SIZE > $MAX bytes ($(($SIZE * 100 / $MAX))%)" >&2)

  [ -z "$UPTRANS" ] || ../../util/b64up.sh "$UPTRANS" "$LFS" || return $?
}



rebuild_and_upload_lfs "$@"; exit $?
