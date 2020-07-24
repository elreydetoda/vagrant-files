#!/usr/bin/env bash

set -${-//[s]/}eu${DEBUG+xv}o pipefail

season=(
  'Spring'
  'Summer'
  'Fall'
  'Autumn'
  'Winter'
)

months=(
  'January'
  'February'
  'March'
  'April'
  'May'
  'June'
  'July'
  'August'
  'September'
  'October'
  'November'
  'December'
)

mutations=()
extra_mutations=()

mutations+=(
  # current year
  "$(date +%Y)"
)
extra_mutations+=(
  # because this makes people feel more secure....
  # listing before regular password because it is more common
 '!'
  # this is so you print out a regular version of the password as well
  ''
)

read -n1 -r -p 'Do you want to include last year? [Y/n] ' include_last_year
# for spacing prompts (prompts go to stderr)
echo 1>&2

case "${include_last_year}" in
  Y|y|'')
    mutations+=( "$(date --date='last year' +%Y)" )
    ;;
esac

# add seasons to password list array
password_list+=( "${season[@]}" )

# append to array with the -O starting at the end of the array
password_list+=( "${months[@]}" )

read -r -p 'what is their min pass policy? ' min_pass_pol

for extra_mutation in "${extra_mutations[@]}" ; do

  for mutation in "${mutations[@]}" ; do

    for password in "${password_list[@]}" ; do

      current_word=$(printf '%s%s%s\n' "${password}" "${mutation}" "${extra_mutation}")

      if [[ "${min_pass_pol}" -le "$(wc -c <<< "${current_word}")" ]] ; then
        echo "${current_word}"
      fi

    done

  done

done
