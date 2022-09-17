CLI_IMPORT=(
    "cli bash key literal"
)

cli::bash::emit::expression::key::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::key() {
    echo -n "["

    cli::bash::key::literal "$1"
    echo -n "${REPLY}"

    echo -n "]"
}

cli::bash::emit::expression::key::self_test() {
    diff <( ${CLI_COMMAND[@]} -- key; echo ) - <<< $'[key]'
}
