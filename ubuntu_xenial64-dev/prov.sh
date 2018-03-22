#!/bin/bash

# always set vim mode =)
sudo -u vagrant sh -c 'echo set editing-mode vi >> /home/vagrant/.inputrc'

## depending on your dev envionment you can set this to make it easy to access your code
#ln -s /coding /home/vagrant/coding

## or you can do this and just make a quick alias, that you call to setup your env
# echo "alias dev='cd /coding/'" >> /home/vagrant/.bashrc

## updates and installs
# always update your box, because you want the most up to date packages
sudo apt-get update

# now do any of your installs here
sudo apt-get install -y screen

# adding some commone sense aliases
echo "alias dev='cd /coding/'" >> /home/vagrant/.bashrc
