#!/usr/bin/env bash

## system
# getting the most up to date packages from the last package
apt-get update
apt-get upgrade -y -o Dpkg::Options::='--force-confnew'
apt-get dist-upgrade -y -o Dpkg::Options::='--force-confnew'

## metasploit
# initializing the msf db
msfdb init
systemctl enable postgresql
systemctl start docker
systemctl enable docker
