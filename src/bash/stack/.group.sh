
cli::bash::stack::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::stack::main() {
    :
}

cli::bash::stack::self_test() {
    echo cli bash stack call --self-test
    echo cli bash stack process --self-test
    echo cli bash stack trace --self-test
    cli bash stack hidden-attribute --self-test
}
