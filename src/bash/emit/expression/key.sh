#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash key literal 

cli::bash::emit::expression::key::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::key::inline() {
    echo -n "["

    cli::bash::key::literal::inline "$1"
    echo -n "${REPLY}"

    echo -n "]"
}

cli::bash::emit::expression::key::self_test() {
    diff <( ${CLI_COMMAND[@]} -- key; echo ) - <<< $'[key]'
}
