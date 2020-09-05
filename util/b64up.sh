#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function b64up_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  # local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  local TRANSPORT="$1"; shift
  local WRAP="$WRAP"
  if [ -z "$WRAP" ]; then
    WRAP="$(stty size | grep -oPe ' \d+$')"
    let WRAP="$WRAP - 10"
  fi
  local MAX_WRAP=1024
  local OUTPIPE=()

  case "$TRANSPORT" in
    pipe ) OUTPIPE=( cat );;
    sc[0-9]* )
      MAX_WRAP=64
      # ^-- Experimentally determined limit (@2020-08-29, with 0.3s
      #     interval) for (usually, mostly) reliable "stuff"ing into
      #     GNU screen v4.01.00devel.
      OUTPIPE=(
        screen-stuff-lines
        # ^-- Available from https://github.com/mk-pmb/terminal-util-pmb/
        "${TRANSPORT#sc}"
        "${UU_DELAY:-0.3s}"
        );;
    * )
      echo "E: unsupported transport: $TRANSPORT" >&2
      return 3;;
  esac

  [ "$WRAP" -le "$MAX_WRAP" ] || WRAP="$MAX_WRAP"
  b64up_encode_these_files "$@" | "${OUTPIPE[@]}"
  local RVSUM="${PIPESTATUS[*]}"
  let RVSUM="${RVSUM// /+}"
  return "$RVSUM"
}


function b64up_encode_these_files () {
  local ORIG=
  for ORIG in "$@"; do
    [ -s "$ORIG" ] || continue
    b64up_encode_one_file "$ORIG" || return $?
  done
}


function b64up_encode_one_file () {
  local ORIG="$1"
  ORIG="${ORIG%/}"
  case "$ORIG" in
    lfs ) b64up_encode_lfs; return $?;;
    *.lua ) b64up_encode_one_lua "$ORIG"; return $?;;
  esac
  local DEST="$(basename -- "$ORIG")"
  echo ">> $ORIG -> $DEST >>" >&2
  b64up_encode_one_file__core
}


function b64up_encode_one_file__core () {
  echo
  echo '>'
  base64 --wrap="$WRAP" -- "$ORIG" || return 3$(
    echo "E: failed to encode $ORIG" >&2)
  echo ">$DEST"
}


function b64up_encode_one_lua () {
  local ORIG="$1"
  local BFN="$(basename -- "$ORIG" .lua)"
  local LCC='.lc-cache'
  mkdir --parents -- "$LCC"
  local DEST="$BFN.lc"

  echo ">> $ORIG -> ($LCC/) $DEST >>" >&2
  luac-for-nodemcu -o "$LCC/$DEST" -- "$ORIG" || return $?$(
    echo "E: failed to compile $ORIG" >&2)

  ORIG="$LCC/$DEST" b64up_encode_one_file__core || return $?
}


function b64up_encode_lfs () {
  local DEST='combined_lfs_.img'

  echo ">> lfs/*.lua -> $DEST >>" >&2
  luac-for-nodemcu -o "$DEST" -f -- lfs/*.lua || return $?$(
    echo "E: failed to compile $DEST" >&2)

  ORIG="$DEST" b64up_encode_one_file__core || return $?
}




b64up_main "$@"; exit $?
