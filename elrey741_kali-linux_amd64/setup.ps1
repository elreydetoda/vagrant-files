
# destroy any current vm and updating box image
vagrant destroy -f
vagrant box update

# starting up and doing all inital provisioning
vagrant up

# snapshotting vm after provisioned
vagrant halt
vagrant snapshot push

# start back up and add containers
vagrant up
vagrant provision --provision-with docker-images

# snapshot vm after containers
vagrant halt
vagrant snapshot push

# start and connect
vagrant up
vagrant ssh
