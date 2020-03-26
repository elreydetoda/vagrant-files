#!/usr/bin/env bash

# non-interactive for apt-get
export DEBIAN_FRONTEND='noninteractive'
shared_folder='/vagrant'
customization_folder="${shared_folder}/customizations"
bash_prompt="${customization_folder}/bash_prompt"

## system base
# getting the most up to date packages from the last package
apt-get update
apt-get dist-upgrade -y -o Dpkg::Options::='--force-confnew'
apt-get install -y \
  vim-gtk3

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
sudo -u vagrant update-alternatives --set editor /usr/bin/vim.gtk3
