#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit expression key

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

::cli::bash::emit::expression::index::inline() {
    echo -n $1
    ::cli::bash::emit::expression::key::inline "$2"
}

cli::bash::emit::expression::index::self_test() {
    diff <( ${CLI_COMMAND[@]} -- MAP key; echo ) - <<< $'MAP[key]'
}
