#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::process::group::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print the group id of $1. 

Description
    By default $1 is the process id of the subprocess. 
EOF
}

cli::process::group() {
    local PID="${1-${BASHPID}}"

    # trim whitespace
    read REPLY < <(ps -p "${PID}" -o pgid=)

    echo "${REPLY}"
}

cli::process::group::self_test() {
    local GPID="$(cli::process::group)"

    # enable job control; new subprocs and their subprocs get their own GPID
    ( [[ $(cli::process::group) == ${GPID} ]] || cli::assert )
    set -m
    ( [[ ! $(cli::process::group) == ${GPID} ]] || cli::assert )
}
