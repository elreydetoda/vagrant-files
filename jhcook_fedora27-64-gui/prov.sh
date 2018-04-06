#!/bin/bash

## personal customizations for my prefered shell environment
# allows me to use vim commands in terminal to move around
sudo -u vagrant sh -c 'echo set editing-mode vi > ~vagrant/.inputrc'

# fix screen flickering from desktop
sudo sed -i 's/^#Wayland.*/WaylandEnable=false/' /etc/gdm/custom.conf

# allows me to have a multiplexer in a multiplexer =)
dnf install -y screen

# installing other packages for lab
# dnf install -y
