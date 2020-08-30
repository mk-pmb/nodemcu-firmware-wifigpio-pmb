# -*- coding: utf-8, tab-width: 2 -*-

function ci_hook_merge_firmware_repos () {
  return 0
  # not currently required

  snip_run '' git remote add mk-pmb \
    'https://github.com/mk-pmb/nodemcu-firmware.git' || return $?
  snip_run '' git fetch mk-pmb || return $?
  snip_run '' git branch dev-pmb mk-pmb/dev || return $?
  snip_run '' git checkout dev-pmb || return $?
  snip_run '' git rebase dev || return $?
}



ci_hook_merge_firmware_repos || return $?
