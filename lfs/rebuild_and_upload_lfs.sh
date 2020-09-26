#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function rebuild_and_upload_lfs () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  [ -x "../$FUNCNAME.sh" ] || return 3$(
    echo "E: This script is meant to be run in an lfs/ subdirectory." >&2)
  local LFS_BFN="$(basename -- "$PWD")"
  cd .. || return $?

  local GITDIR="$(dirname -- "$PWD")/.git"
  local FWSRC="$GITDIR/@fwsrc"
  [ -f "$FWSRC"/Makefile ] || return 3$(
    echo "E: Please make $FWSRC a symlink to your firmware source repo." >&2)

  local BAGA="$GITDIR/@baga"
  [ -f "$BAGA"/build.sh ] || return 3$(
    echo "E: Please make $BAGA a symlink to the BAGA repo." >&2)

  export INPUT_FIRMWARE_SRCDIR="$FWSRC"
  ./_prepare.sh || return $?
  "$BAGA"/build.sh build_one_prepared_lfs_image "$LFS_BFN" || return $?

  local LFS_IMG="$LFS_BFN.lfs"
  local MAX=0 SIZE="$(stat -c %s -- "$LFS_IMG")"
  [ -n "$SIZE" ] || return 3$(echo "E: unable to measure the LFS size" >&2)
  let MAX="${MAXLFS_KB:-64} * 1024"
  [ "$SIZE" -le "$MAX" ] || return 3$(
    echo "E: LFS too big: $SIZE > $MAX bytes ($(($SIZE * 100 / $MAX))%)" >&2)

  [ -z "$UPTRANS" ] || ../util/b64up.sh "$UPTRANS" \
    "$LFS_IMG?fx=reLFS" || return $?
}



rebuild_and_upload_lfs "$@"; exit $?
