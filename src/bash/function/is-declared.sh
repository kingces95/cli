#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::function::is_declared::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return true if the function is declared, otherwise false.

Arguments
    Argumetn \$1 is the name of the function.
EOF
}

cli::bash::function::is_declared::inline() {
    declare -F "${1-}" > /dev/null
}

cli::bash::function::is_declared::self_test() {
    cli::bash::function::is_declared::inline \
        cli::bash::function::is_declared::self_test || cli::assert
    ! cli::bash::function::is_declared::inline missing || cli::assert
}
