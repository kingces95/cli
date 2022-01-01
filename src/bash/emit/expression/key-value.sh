#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit expression key
cli::source cli bash emit initializer string

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

::cli::bash::emit::expression::key_value::inline() {
    ::cli::bash::emit::expression::key::inline "$1"
    echo -n '='
    ::cli::bash::emit::initializer::string::inline "$2"
}

cli::bash::emit::expression::key_value::self_test() {
    local MY_VALUE=value
    diff <( ${CLI_COMMAND[@]} -- key MY_VALUE; echo ) - <<< $'[key]="value"'
}
