alias v-connect="vagrant up && case \${v_headless} in true) extra_cmds=( '-c' 'exit') ;; *) extra_cmds=() ;; esac ; vagrant ssh \${extra_cmds[@]} || return 1"
alias v-newz='vagrant destroy -f && vagrant up'
alias v-newz_up='vagrant destroy -f && vagrant box update && v-connect'
alias v-snap_conn='vagrant halt && vagrant snapshot push && v-connect'
alias v-newz_conn='vagrant destroy -f && v-connect'
alias v-newz_up_conn='export v_headless=true ; v-newz_up ; unset v_headless ; v-connect '
alias v-newz_up_snap_conn='export v_headless=true ; if v-newz_up ; then unset v_headless ; v-snap_conn ; else unset v_headless; return 1 ; fi'
alias v-newz_snap_conn='v-newz && v-snap_conn'
alias v-reload_conn='vagrant reload && vagrant ssh'
alias v-revert_conn='vagrant snapshot pop --no-delete && vagrant ssh'
alias v-revert_prov_conn='vagrant snapshot pop --no-delete --provision && vagrant ssh'
alias v-config="grep -vP '^\s+#|^#|^$' Vagrantfile"
alias v-aliases="alias | grep '^v-'"
alias v-aliases_wanted="grep '^alias v-' ~/.zshrc"
alias v-edit="${EDITOR} Vagrantfile"
