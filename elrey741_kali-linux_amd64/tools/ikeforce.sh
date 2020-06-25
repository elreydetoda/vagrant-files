#!/usr/bin/env bash

set -${-//[s]/}eu${DEBUG+xv}o pipefail

commands_to_run=()
for command_item in ${1} ; do
    commands_to_run+=( "${command_item}" )
done

docker container run --rm --name ikeforce-elrey elrey741/ikeforce "${commands_to_run[@]}"
