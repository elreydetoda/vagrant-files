#!/usr/bin/env bash

# non-interactive for apt-get
export DEBIAN_FRONTEND='noninteractive'
shared_folder='/vagrant'
customization_folder="${shared_folder}/customizations"
bash_prompt="${customization_folder}/bash_prompt"

## system base
# getting the most up to date packages from the last package
apt-get update
apt-get upgrade -y -o Dpkg::Options::='--force-confnew'
apt-get dist-upgrade -y -o Dpkg::Options::='--force-confnew'

## metasploit
# initializing the msf db
msfdb init
# enabling msf database to start at boot
systemctl enable postgresql

# starting docker and enabling
systemctl enable --now docker

if [[ -f "${bash_prompt}" ]] ; then
  cat "${bash_prompt}" >> ~vagrant/.bashrc
fi
