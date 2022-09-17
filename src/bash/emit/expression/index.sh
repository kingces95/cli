CLI_IMPORT=(
    "cli bash emit expression key"
)

cli::bash::emit::expression::index::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::index() {
    echo -n $1
    cli::bash::emit::expression::key "$2"
}

cli::bash::emit::expression::index::self_test() {
    diff <( ${CLI_COMMAND[@]} -- MAP key; echo ) - <<< $'MAP[key]'
}
