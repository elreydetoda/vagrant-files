#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

function get_aliases(){
  grep '^alias v-' "${shell_rc_file}"
}

function main(){
  shell_rc_file="${HOME}/.zshrc"

  get_aliases
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
