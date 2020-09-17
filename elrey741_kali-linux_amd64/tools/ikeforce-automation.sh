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

# TODO: make concurrency nicer to where it spits out everything to a mkdtemp -d dir and reconstructs
#   it with a cat mktemp -d * to log file
# TODO: then there is a cleanup function to rm -rf "${folder_array[@]}" if fail or when finish

# TODO: implement this
function initial_scan(){

  ikeforce_folder='/client_data/test-data/<client_folder>'
  ikeforce_tmp_output_folder='/client_data/test-data/<client_folder>/ikeforce-output'
  ikeforce_file_prefix="$(date -I )"
  ikeforce_log_file_with_prefix="${ikeforce_folder}/${ikeforce_file_prefix}"
  # ikeforce_initial_log_file="${ikeforce_log_file_with_prefix}_00_ike-scan_results.log"
  ikeforce_initial_log_file="${ikeforce_folder}/2020-06-30_ike-scan_results.log"
  ikeforce_secondary_log_file="${ikeforce_log_file_with_prefix}_01_ike-scan_results.log"
  
  # TODO: implement concurrency for this with a wait "${pid_array[@]}" at the end
  # initial scan for valid hosts
  # time (
  #     for host in $(cat ike_hosts) ; do
  #         printf 'starting scan for: %s\n' "${host}" && ~vagrant/tools/ikeforce.sh "${host} -a"
  #     done
  # ) |& tee "${ikeforce_initial_log_file}"
  # time (
  #     for i in $(cat ike_hosts ) ; do
  #         printf 'starting scan for: %s\n' "${i}" && ~vagrant/tools/ikeforce/ikeforce.py "${i}" -a
  #     done
  # ) |& tee "$(date -I)_ike-scan_results_not-docker.log"

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
    grep -B 7 '|' "${ikeforce_initial_log_file}" |
    grep -oP '\d+\.\d+\.\d+\.\d+(\/.\d+|)'
  )


  # echo "${ikeforce_ip_results[@]}"

  # declaring array to store results
  declare -A ip_and_results

  for valid_ip_address in "${ikeforce_ip_results[@]}" ; do

    # adding to associated array for results per ip
    ip_and_results["${valid_ip_address}"]="$(

      # greping for valid ip address in results
      grep -A 7 "${valid_ip_address}" "${ikeforce_initial_log_file}" |

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

  pid_array=()
  local sec_wait=30

  # ikeforce_secondary_log_file_tmp="${ikeforce_secondary_log_file##*/}"

  rm -f "${ikeforce_secondary_log_file}"-*

  sleep 5
  time for ip in "${!ip_and_transforms[@]}" ; do
    # printf 'ip=%s\nvalue=%s\n' "${ip}" "${ip_and_transforms[${ip}]}"
    current_output="${ikeforce_secondary_log_file}-${ip}"
    printf 'starting scan for: %s\n' "${ip}" &>> "${current_output}"
    ~vagrant/tools/ikeforce.sh "${ip} -e -w wordlists/groupnames.dic -t ${ip_and_transforms[${ip}]}"  &>> "${current_output}" &
    pid_array+=( "$!")
  done 

  printf 'waiting for %d seconds\n' "${sec_wait}"
  wait_print "${sec_wait}"

  if ! kill -9 "${pid_array[@]}" 2>/dev/null ; then
    echo "Jobs have completed."
  fi
}

function wait_print(){
  local sec_wait="${1}"
  waited=0

  until [[ "${waited}" -eq "${sec_wait}" ]] ; do
    printf '.' && sleep 1 && waited=$((waited+1))
  done
  
  echo
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

  parse_input "${@}"

  # DEBUG
  # printf '%s\n' "${host_array[@]}"

  # initial_scan
  # parse_initial_results
  # secondary_scan
}

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
