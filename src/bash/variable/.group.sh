
cli::bash::variable::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::variable::main() {
    :
}

cli::bash::variable::self_test() {
    cli bash variable declaration .group --self-test
    cli bash variable declare-enum --self-test
    cli bash variable emit --self-test
    cli bash variable get-info --self-test
    cli bash variable list --self-test
}
