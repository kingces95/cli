
cli::bash::function::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::function::main() {
    :
}

cli::bash::function::self_test() {
    cli bash function is-declared --self-test
    cli bash function list --self-test
}
