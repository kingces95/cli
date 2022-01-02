#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::process::group::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Set REPLY to the group id of $1. 

Description
    By default $1 is the process id of the subprocess. 
EOF
}

main() {
    cli::proc::parent::inline "$@"
    declare -p REPLY
}

cli::process::parent::inline() {
    local PID=${1-${BASHPID}}
    read < <(ps -p $$ -o pgid=)
}

cli::process::group::self_test() {
    :
}
