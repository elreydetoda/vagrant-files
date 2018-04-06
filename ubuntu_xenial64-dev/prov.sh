#!/bin/bash

U=vagrant

# always set vim mode =)
sudo -u $U sh -c "echo set editing-mode vi >> /home/${U}/.inputrc"

## updates and installs
# always update your box, because you want the most up to date packages
sudo apt-get update

# now do any of your installs here
sudo apt-get install -y screen

# adding some commone sense aliases
echo "alias dev='cd /coding/'" >> /home/${U}/.bashrc
echo "alias v='cd /vagrant/'" >> /home/${U}/.bashrc
echo "alias screen='screen -q'" >> /home/${U}/.bashrc
