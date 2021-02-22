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

function current_client(){

  read -rp 'What is the name of your current client? ' client_name ; echo # echo is for the new line
  current_date="$(date -I)"
  sed -i "s/%CLIENT_NAME%/${current_date}-${client_name}/" Vagrantfile

}

function main(){

  # cleanup old env
  prep_env

  if [[ -f "Vagrantfile.client" ]] ; then
    cp -v Vagrantfile.client Vagrantfile
    # starting new env
    current_client
  fi

  # initializing new env
  init

  snapshot
  containers
  snapshot
  vagrant ssh
}

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
