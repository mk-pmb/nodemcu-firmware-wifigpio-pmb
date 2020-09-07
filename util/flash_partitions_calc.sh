#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function pt_calc () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"

  local BLKSZ=$(( 8 * 1024 ))
  local PRTN="$*"
  if [ -z "$PRTN" ]; then
    echo 'Query: = sjson.encode(node.getpartitiontable())'
    read -rp 'Reply: ' PRTN
  fi
  case "$PRTN" in
    maxfw ) pt_preview_config_maxfw || return $?;;
  esac

  local PTBL=()
  readarray -t PTBL < <(<<<"$PRTN" tr '{},' '\n' | tr -d '\t \r"' \
    | LANG=C sort | sed -nrf <(echo '
    N;s~^([a-z_]+)_addr:([0-9]+)\n[[a-z_]+_size:([0-9]+)$~\2 \3 \1~p
    ') | sort --general-numeric-sort)
  local USED=0 ADDR= SIZE=
  for PRTN in "${PTBL[@]}"; do
    ADDR="${PRTN%% *}"; PRTN="${PRTN#* }"
    SIZE="${PRTN%% *}"; PRTN="${PRTN#* }"
    pt_numfmt '+' $(( ADDR - USED )) '=@' "$ADDR"
    let USED="$ADDR + $SIZE"
    BLKSZ=1 pt_numfmt '+' "$SIZE" '=…' "$USED"
    echo "$PRTN"
  done
}


function pt_numfmt () {
  local ITEM= MISAL=
  for ITEM in "$@"; do
    case "$ITEM" in
      *[0-9] )
        printf '% 5s KiB' "$(( ITEM / 1024 ))"
        [ "$ITEM" -ge 0 ] || echo -n "<-{W: unexpected negative number}"
        MISAL=
        let MISAL="$ITEM % BLKSZ"
        [ "$MISAL" == 0 ] || echo -n "<-{W: misaligned by $MISAL bytes}"
        echo -n $'\t'
        ;;
      * ) echo -n "$ITEM"
    esac
  done
}


function pt_preview_config_maxfw () {
  local -A CFG=( [file]="$SELFPATH/../esp8266.app.include/config.h" )
  eval "CFG=( $(gcc -E -dM "${CFG[file]}" | sed -nrf <(echo '
    s~^#define (FLASH_)([0-9x]+[KM]) ?$~[\1]=\2~p
    s~^#define ([A-Z][A-Z0-9_]+) ([0-9x]+)$~[\1]=$((\2))~p
    ')) )"
  local SPIFFS_ADDR="${CFG[SPIFFS_FIXED_LOCATION]:-0}"
  [ "$SPIFFS_ADDR" -ge 1 ] || return 4$(
    echo "E: maxfw mode requires a positive SPIFFS_FIXED_LOCATION." >&2)
  local LFS_SIZE="${CFG[LUA_FLASH_STORE]:-0}"
  local LFS_ADDR=$(( ( (SPIFFS_ADDR - LFS_SIZE) / BLKSZ ) * BLKSZ ))
  local FLASH_SIZE="${CFG[FLASH_]:-0}"
  FLASH_SIZE="${FLASH_SIZE/%M/*1024K}"
  FLASH_SIZE="${FLASH_SIZE/%K/*1024}"
  let FLASH_SIZE="$FLASH_SIZE"
  local SPIFFS_SIZE=$(( FLASH_SIZE - SPIFFS_ADDR - (4*1024) ))
  printf -v PRTN '"%s":%s, ' \
    firmware_addr 0 \
    firmware_size "$LFS_ADDR" \
    lfs_addr "$LFS_ADDR" \
    lfs_size "$LFS_SIZE" \
    spiffs_addr "$SPIFFS_ADDR" \
    spiffs_size "$SPIFFS_SIZE" \
    ;
  PRTN="{ ${PRTN%, } }"
  local FPTB="{ ${PRTN#*, *, }"
  FPTB="${FPTB//:/=}"
  FPTB="${FPTB//$'\x22'/}"
  echo "= node.setpartitiontable($FPTB)"
}








pt_calc "$@"; exit $?
