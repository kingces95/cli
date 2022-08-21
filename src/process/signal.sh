#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli process group"
)

cli::process::signal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Issue control-c. 

Description
    Send signal $1 to all processes in the same process group id as the subshell.
    
    By default $1 is SIGINT which is equivilant to a control-c from the terminal.
EOF
}

cli::process::signal() {
    local SIGNAL=${1-SIGINT}
    local PGID=$(cli::process::group)
    kill "-${SIGNAL}" "-${PGID}"
}

cli::process::signal::self_test() (
    local GPID=$(cli::process::group)

    # enable job control; new subprocs and their subprocs get their own GPID
    ( [[ $(cli::process::group) == ${GPID} ]] || cli::assert )
    set -m
    ( [[ ! $(cli::process::group) == ${GPID} ]] || cli::assert )

    # do not trap if function fails
    set +e 
    false   # this will trap and exit without `set +e`

    (
        [[ ! $(cli::process::group) == ${GPID} ]] || cli::assert
        cli::process::signal
        return 0
    )
    (( ! $? == 0 )) || cli::assert

    (
        [[ ! $(cli::process::group) == ${GPID} ]] || cli::assert
        sleep 1 | cli::process::signal | sleep 1
        return 0
    )
    (( ! $? == 0 )) || cli::assert
)
