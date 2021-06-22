#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JZOgH

function prep(){
  rm -f livehosts_n_ports
}

function get_hostnport(){

  mapfile -t singluar_port_results < <(
    # skip the nmap header
    tail -n+2 "${1}" |

      # skip the nmap footer
      grep -vE '(scanned|Up)' |

      # remove Host: as well as () from gnmap format
      cut -d ' ' -f 2,4- |

      # ignoring lines ending with ( Ignored... amount of ports.. )
      #   this is handled in the next array
      grep -v '( Ignored' |

      # remove the blank lines
      grep -v '^$'
  )

  mapfile -t not_singluar_port_results < <(
    # skip the nmap header
    tail -n+2 "${1}" |

      # skip the nmap footer
      grep -vE '(scanned|Up)' |

      # remove Host: as well as () from gnmap format
      cut -d ' ' -f 2,4- |

      # only grabbing lines that endings with ( Ignored
      grep '( Ignored' |

      # reverse to more easily remove uncessary ending lines ( Ignored... amount of ports.. )
      rev |

      # removed ending lines
      cut -d ' ' -f 5- |

      # put string back to normal
      rev |

      # remove the blank lines
      grep -v '^$'
  )

  results+=( "${singluar_port_results[@]}" "${not_singluar_port_results[@]}" )
  #printf '%s\n' "${results[@]}" | cat -A

}

function format_host_n_ips(){

  for line in "${results[@]}" ; do

    # example line:
    # 192.168.1.1 80/open/tcp//http///, 135/open/tcp//msrpc///, 139/open/tcp//netbios-ssn///, 443/open/tcp//https///, 445/open/tcp//microsoft-ds///,

    host_ip="$( echo "${line}" | cut -d ' ' -f 1 )"

    # this had to be seperated out because if they are empty they would fail
    port_line="$(echo "${line}" | cut -d ' ' -f 2- )"

    # the IP address will be in the port_line var if
    #   there are no open ports, so checking for that here
    if [[ "${host_ip}" != "${port_line}" ]] ; then

      # checking if the port was open
      if grep '/open/' <<< "${port_line}" >/dev/null ; then

        # checking if there is only port returned
        if grep ',' <<< "${port_line}" >/dev/null ; then

          open_ports="$(
            # getting all the ports
            echo "${port_line}" |

              # make all open ports on their own line
              tr ',' '\n' |

              # remove extra whitespace
              tr -d ' |\t' |

              # remove blank lines
              grep -v '^$' |

              # get only the port numbers
              grep -oP '^\d+' |

              # put them all comma delimited now
              tr '\n' ',' |

              # remove trailing comma
              sed 's/,$//'
          )"

        else

          # this is if there are multiple ports returned
          open_ports="$(
            # getting all the ports
            echo "${port_line}" |

              # remove extra whitespace
              tr -d ' |\t' |

              # get only the port numbers
              grep -oP '^\d+'
          )"

        fi

        printf "%s %s\n" "$host_ip" "$open_ports" >> "livehosts_n_ports"
      else
        printf '%s did not have any open ports\n' "${host_ip}"
      fi
    else
      printf '%s did not have any open ports\n' "${host_ip}"
    fi

  done

}

function main(){
  if [[ "$#" -ne 1 ]] || [[ "$( echo "${1:-}" | cut -c 1-3 | rev | cut -d '-' -f 1 | rev )" == 'h' ]]; then
    echo "You need to pass in the gnmap output of your scan"
    exit 1
  fi

  declare -a results

  prep
  get_hostnport "${1}"
  format_host_n_ips
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi

