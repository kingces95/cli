#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::return::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Returns 0.

Description
    Returns the first positonal argument. Default is 0.
EOF
}

cli::bash::return::inline() {
    return ${1-0}
}

cli::bash::return::self_test() {
    cli::bash::return::inline || cli::assert
    ! cli::bash::return::inline 1 || cli::assert
}
