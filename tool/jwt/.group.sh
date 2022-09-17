
cli::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description

EOF
}

jwt::main() {
    :
}

jwt::self_test() {
    jwt parse --self-test
}
