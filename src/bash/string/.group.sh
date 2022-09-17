
cli::bash::string::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::string::main() {
    :
}

cli::bash::string::self_test() {
    cli bash string literal --self-test
}
