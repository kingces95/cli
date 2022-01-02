#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli bash emit expression key"
    "cli bash emit initializer string"
)

cli::bash::emit::expression::key_value::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::key_value() {
    cli::bash::emit::expression::key "$1"
    echo -n '='
    cli::bash::emit::initializer::string "$2"
}

cli::bash::emit::expression::key_value::self_test() {
    local MY_VALUE=value
    diff <( ${CLI_COMMAND[@]} -- key MY_VALUE; echo ) - <<< $'[key]="value"'
}
