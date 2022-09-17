
cli::core::variable::name::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
    resolve - given a variable, type, and fields, resolve the bash variable
EOF
}

cli::core::variable::name::main() {
    :
}

cli::core::variable::name::self_test() {
    cli core variable name resolve --self-test
    cli core variable name fields --self-test
    cli core variable name modifications --self-test
}
