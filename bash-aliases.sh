#!/usr/bin/env bash
alias v-connect_insecure="vagrant up && vagrant ssh"
alias v-connect="diff <(v-config | sha1sum ) <( cat Vagrantfile.sha1 ) && vagrant up && vagrant ssh || echo 'shasum mismatch check your Vagrantfile' && sleep 3 && ${EDITOR} Vagrantfile"
alias v-connect_no_prov="diff <(v-config | sha1sum ) <( cat Vagrantfile.sha1 ) && vagrant up --no-provision && vagrant ssh || echo 'shasum mismatch check your Vagrantfile' && sleep 3 && ${EDITOR} Vagrantfile"
alias v-newz='vagrant destroy -f && v-connect'
alias v-newz_no_prov='vagrant destroy -f && v-connect_no_prov'
alias v-newz_up='vagrant destroy -f && vagrant box update && v-connect'
alias v-newz_up_no_prov='vagrant destroy -f && vagrant box update && v-connect_no_prov'
alias v-snap_conn='vagrant halt && vagrant snapshot push && v-connect'
alias v-snap_conn_no_prov='vagrant halt && vagrant snapshot push && v-connect_no_prov'
alias v-newz_conn='vagrant destroy -f && v-connect'
alias v-newz_up_conn='v-newz_up && v-connect'
alias v-newz_up_snap_conn='v-newz_up && v-snap_conn'
alias v-newz_snap_conn='v-newz && v-snap_conn'
alias v-reload_conn='vagrant reload && vagrant ssh'
alias v-revert_conn='vagrant snapshot pop --no-delete && vagrant ssh'
alias v-revert_prov_conn='vagrant snapshot pop --no-delete --provision && vagrant ssh'
alias v-config="grep -vP '^\s+#|^#|^$' Vagrantfile"
alias v-aliases="grep '^alias v-' ~/.zshrc"
alias v-edit="${EDITOR} Vagrantfile && v-config | sha1sum | sudo tee Vagrantfile.sha1"
function v-stop_all(){
  # stop all running vagrant boxes
  for box in $(vagrant global-status | grep -oP '\srunning\s+/.*' | cut -d ' ' -f 4-) ; do
    pushd "${box}" || return 1 && vagrant halt && popd || return 1
  done
}
