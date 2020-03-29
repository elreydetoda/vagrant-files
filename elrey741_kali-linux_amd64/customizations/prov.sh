#!/usr/bin/env bash

set -euo pipefail
# debug
set -x

##################################################
## Variables
# non-interactive for apt-get
export DEBIAN_FRONTEND='noninteractive'
shared_folder='/vagrant'
customization_folder="${shared_folder}/customizations"
bash_prompt="${customization_folder}/bash_prompt"

apt_pkgs=(
  'vim-gtk3' # my personal preference: https://blog.elreydetoda.site/vim-clipboard-over-ssh/
  'glances' # use as system monitor
  'jq' # used for parsing json
  'snapd' # used for installing tools
  'xclip' # used for clipboard access over x11
)

snap_pkgs_classic=(
  'go' # for different go offensive tools
  'code' # for code editing/analyzing from searchsploit
)

snap_pkgs=(
  'docker' # used for tools
  'postman' # API testing tool
)

##################################################

## system base
# getting the most up to date packages from the last package
apt-get update
apt-get dist-upgrade -y -o Dpkg::Options::='--force-confnew'

## extras
# installing all apt based tools
apt-get install -y "${apt_pkgs[@]}"

# starting and enabling all snapd deps
systemctl enable --now snapd apparmor

snap install "${snap_pkgs[@]}"

# installing all snap based tools
for snap in "${snap_pkgs_classic[@]}" ; do
  snap install "${snap}" --classic
done

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

# setting my preference of using vim mode with bash
printf 'set editing-mode vi\n' >> ~vagrant/.inputrc

# setting my favorite editor (because of clipboard support)
update-alternatives --set editor /usr/bin/vim.gtk3
