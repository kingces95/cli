
cli::bash::emit::expression::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::emit::expression::main() {
    :
}

cli::bash::emit::expression::self_test() {
    cli bash emit expression declare --self-test
    cli bash emit expression index --self-test
    cli bash emit expression key --self-test
    cli bash emit expression key-value --self-test
    cli bash emit expression map --self-test
    cli bash emit expression array --self-test
}
