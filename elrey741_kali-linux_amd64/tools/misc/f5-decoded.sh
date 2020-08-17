#!/usr/bin/env bash

set -${-//[s]/}eu${DEBUG+xv}o pipefail

# steps provided from here: https://support.f5.com/csp/article/K6917
# example encoded cookie: 1677787402.36895.0000


function generate_hex_array(){
  f5_orig_val="${1}"

  f5_hex_string="$( printf "%X" "${f5_orig_val}" )"
  
  printf 'cookie for %s converted to hex value: %s\n' "${2}" "${f5_hex_string}"

  for (( i=0; i<${#f5_hex_string}; i+=2 )) ; do
    f5_hex_array+=("${f5_hex_string:$i:2}")
  done
}

function print_f5_ip(){

  # this is the final value
  ip_addr=$(for hex_val in "${f5_hex_array[@]}" ; do
    current_hex_value="0x${hex_val}"
    printf '%d\n' "${current_hex_value}" 
  done | tac | tr '\n' '.' | sed 's/.$//')

  ###################################################
  ## this is for output to put in report

  # reversed hex values
  printf 'hex values reversed: '
  for hex_val in "${f5_hex_array[@]}" ; do
    current_hex_value="0x${hex_val}"
    printf '%s\n' "${current_hex_value}" 
  done  | tac | tr '\n' ' ' | sed 's/\s$//' ; echo

  # digit version of hex
  printf 'converted decimal numbers: '
  for hex_val in "${f5_hex_array[@]}" ; do
    current_hex_value="0x${hex_val}"
    printf '%d\n' "${current_hex_value}" 
  done  | tac | tr '\n' ' ' | sed 's/\s$//' ; echo
  ###################################################
}

function print_f5_port(){

  # this is the final value
  port_num=$(for hex_val in "${f5_hex_array[@]}" ; do
    printf '%s\n' "${hex_val}"
  done | tac | tr -d '\n' | sed 's/^/0x/' | xargs -I {} printf '%d' "{}" )

  ###################################################
  ## this is for output to put in report

  printf 'hex value reversed: '
  for hex_val in "${f5_hex_array[@]}" ; do
    printf '%s\n' "${hex_val}"
  done  | tac | tr -d '\n' | sed 's/^/0x/' ; echo

  printf 'hex value converted: '
  for hex_val in "${f5_hex_array[@]}" ; do
    printf '%s\n' "${hex_val}"
  done  | tac | tr -d '\n' | sed 's/^/0x/' | xargs -I {} printf '%d' "{}" ; echo

  ###################################################
}

function cleanup(){
  f5_hex_array=()
}

function main(){

  f5_cookie_orig="${1}"

  f5_cookie_orig="${f5_cookie_orig/%.0000/}"

  ip_cookie=${f5_cookie_orig%.*}
  ip_port=${f5_cookie_orig#*.}

  declare -a f5_hex_array

  generate_hex_array "${ip_cookie}" 'ip'
  print_f5_ip
  cleanup
  generate_hex_array "${ip_port}" 'port'
  print_f5_port
  printf 'final result is below\n%s:%s\n' "${ip_addr}" "${port_num}"
 }

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
