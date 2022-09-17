
cli::bash::emit::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::emit::main() {
    :
}

cli::bash::emit::self_test() {
    cli bash emit block .group --self-test
    cli bash emit expression .group --self-test
    cli bash emit initializer .group --self-test
    cli bash emit statement .group --self-test
    cli bash emit function --self-test
    cli bash emit indent --self-test
    cli bash emit variable --self-test
}
