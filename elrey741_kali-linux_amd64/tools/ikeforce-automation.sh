#!/usr/bin/env bash

set -${-//[s]/}eu${DEBUG+xv}o pipefail

function parse_input(){

  # check if file
  if [[ -f "${1}" ]] ; then

    # parse file passed
    mapfile -t host_array < "${1}"

  # if it's not empty
  elif [[ -n "${1}" ]] ; then

    case "${1}" in
      *\|*)

          # parse | delimited string of hosts
          mapfile -t host_array < <( tr '|' '\n' <<< "${1}" )

        ;;
        *)

          # only one host
          host_array+=( "${1}" )

        ;;
    esac

  else
    echo 'Something weird happened...'
    printf 'this was the value that was interpreted %s\n' "${1}"
  fi

}

function initial_scan(){

  local pid_array=()
  # TODO: make dynamic based on number of hosts
  sec_wait=300

  ikeforce_folder="${current_folder_path}/ikeforce"
  initial_tmp_folder="$(mktemp -d)"
  ikeforce_file_prefix="$(date -I )"
  ikeforce_log_file_with_prefix="${ikeforce_folder}/ikeforce-${ikeforce_file_prefix}.log"
  initial_final_log_file="${ikeforce_folder}/ikeforce_01_scan-results.log"

  mkdir -p "${ikeforce_folder}"

  for host in "${host_array[@]}" ; do
    printf 'starting scan for: %s\n' "${host}" |& tee -a "${initial_tmp_folder}/${host}-initial_ikeforce-scan.log"
    ${path_to_ikeforce_wrapper} "${host} -a" &>> "${initial_tmp_folder}/${host}-initial_ikeforce-scan.log" &
    pid_array+=( "$!" )
  done

  printf '\n\nwaiting for all processes to complete\n'
  printf 'run this if you want to see the containers status: %s\n' 'watch -n 1 "docker container ls"'
  # shellcheck disable=SC2016
  printf 'if this is taking too long you can run this: %s $(%s)\n' "docker rm -f" "docker container ls --format '{{.ID}}' | tr '\n' ' '"

  process_waiting "${pid_array[@]}"

  mapfile -t docker_ids < <( docker container ls --format '{{.ID}}' )
  if ! kill -9 "${pid_array[@]}" 2>/dev/null ; then
    echo "Jobs have completed."
  else
    docker rm -f "${docker_ids[@]}"
    echo "had to manually kill jobs"
  fi

  cat "${initial_tmp_folder}/"* > "${initial_final_log_file}"

  if [[ "${CLEANUP}" == true ]] ; then
    rm -rvf "${initial_tmp_folder}" |& tee "${ikeforce_log_file_with_prefix}"
  fi

}

function parse_initial_results(){
  # example successful result
  # starting scan for: x.x.x.x
  # [+]Program started in Transform Set Enumeration Mode
  # [+]Checking for acceptable Transform# 
  # ============================================================================================
  # Accepted (AM) Transform Sets
  # ============================================================================================
  # | 5 : 3DES-CBC | 2 : SHA | 65001 : XAUTHInitPreShared | 2 : alternate 1024-bit MODP group |
  # --------------------------------------------------------------------------------------------
  # ============================================================================================
  # Shutting down server

  mapfile -t ikeforce_ip_results < <(
    # grep only strings that have a '|' which indicates it came back with results
    grep -B 9 '|' "${initial_final_log_file}" |
    grep -oP '\d+\.\d+\.\d+\.\d+(\/.\d+|)'
  )


  echo "${ikeforce_ip_results[@]}"

  # declaring array to store results
  declare -A ip_and_results

  for valid_ip_address in "${ikeforce_ip_results[@]}" ; do

    # adding to associated array for results per ip
    ip_and_results["${valid_ip_address}"]="$(

      # greping for valid ip address in results
      grep -A 7 "${valid_ip_address}" "${initial_final_log_file}" |

      # greping for results string
      grep '|'
    )"

  done

  for ip in "${!ip_and_results[@]}" ; do
    # printf 'ip=%s\nvalue=%s\n' "${ip}" "${ip_and_results[${ip}]}"

    # adding to another associated array for all transforms
    ip_and_transforms["${ip}"]="$(

      # printing out results per ip
      printf '%s' "${ip_and_results[${ip}]}" |

      # only grep digits that match up to a ':'
      grep -oP '\d+\s+:' |

      # only grep digits
      grep -oP '\d+' |

      # comma delimit them
      tr '\n' ' ' |

      # remove trailing comma
      sed 's/ $//'
    )"

  done

}

function secondary_scan(){

  local pid_array=()
  sec_wait=30

  secondary_tmp_folder="$(mktemp -d)"
  secondary_final_log_file="${ikeforce_folder}/ikeforce_02_scan-results.log"

  for ip in "${!ip_and_transforms[@]}" ; do
    # printf 'ip=%s\nvalue=%s\n' "${ip}" "${ip_and_transforms[${ip}]}"
    current_output="${secondary_tmp_folder}/${ip}-second_ikeforce.log"
    printf 'starting scan for: %s\n' "${ip}" &>> "${current_output}"
    ${path_to_ikeforce_wrapper} "${ip} -e -w wordlists/groupnames.dic -t ${ip_and_transforms[${ip}]}"  &>> "${current_output}" &
    pid_array+=( "$!")
  done 

  process_waiting "${pid_array[@]}"

  mapfile -t docker_ids < <( docker container ls --format '{{.ID}}' )
  if ! kill -9 "${pid_array[@]}" 2>/dev/null ; then
    echo "Jobs have completed."
  else
    docker rm -f "${docker_ids[@]}"
    echo "had to manually kill jobs"
  fi

  cat "${secondary_tmp_folder}/"* > "${secondary_final_log_file}"

  if [[ "${CLEANUP}" == true ]] ; then
    rm -rvf "${secondary_tmp_folder}" |& tee -a "${ikeforce_log_file_with_prefix}"
  fi

}

function process_waiting(){
  local pid_array=()
  mapfile -t pid_array < <( printf '%s\n' "${@}" )

  printf 'waiting for %d seconds\n\n' "${sec_wait}"
  wait_print "${sec_wait}"

}

function wait_print(){
  local sec_wait="${1}"
  waited=0

  until [[ "${waited}" -eq "${sec_wait}" ]] ; do
    printf '%ds/%ds' "${waited}" "${sec_wait}" && sleep 1 && waited=$((waited+1))
    if [[ "$(pgrep -u "${USER}" docker | wc -l)" -eq 0 ]] ; then
      break
    fi
    # https://stackoverflow.com/questions/5799303/print-a-character-repeatedly-in-bash#answer-17030976
    printf '\r' && printf '%0.s ' {1..20} && printf '\r'
  done
  
  printf '\n\n'
}

# TODO: implement
function third_scan(){
  printf
}

function main(){

  if [[ $# -ne 1 ]] ; then

    echo 'Please pass in ga file or ip address as input'
    echo 'if you have multiple IP addresses, then delimit them by |'
    exit 1

  fi
  # declaring array to store transforms
  declare -A ip_and_transforms
  host_array=()
  current_folder_path="$(pwd -P)"
  # DEBUG
  # CLEANUP="false"
  CLEANUP="${CLEANUP:-true}"
  path_to_ikeforce_wrapper="${HOME}/tools/ikeforce.sh"

  parse_input "${@}"

  # DEBUG
  # printf '%s\n' "${host_array[@]}"

  initial_scan
  parse_initial_results
  secondary_scan
}

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
