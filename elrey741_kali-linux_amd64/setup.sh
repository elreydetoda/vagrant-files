#!/usr/bin/env bash

set -${-//[sc]/}eu${DEBUG+xv}o pipefail

function prep_env(){
  vagrant destroy -f
  vagrant box update
}

function init(){
  vagrant up
}

function snapshot(){
  vagrant halt
  vagrant snapshot push
  init
}

function containers(){
  vagrant provision --provision-with docker-images
}

function main(){
  prep_env
  init
  snapshot
  containers
  snapshot
  vagrant ssh
}

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
