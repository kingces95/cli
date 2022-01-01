#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Set REPLY to the process id of $1. 

Description
    By default $1 is the process id of the subprocess. 
EOF
}

main() {
    ::cli::proc::parent::inline "$@"
    declare -p REPLY
}

::cli::process::parent::inline() {
    local PID=${1-${BASHPID}}
    read < <(ps -p ${PID} -o ppid=)
}

cli::process::parent::self_test() {
    ( 
        ::cli::process::parent::inline
        [[ "${REPLY}" == "$$" ]] || cli::assert "${REPLY}" == "$$"
    )
}
