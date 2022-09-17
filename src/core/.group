
cli::core::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::core::main() {
    readonly CLI_CORE_REGEX_TYPE_NAME="^[a-z][a-z0-9_]*$"
    readonly CLI_CORE_REGEX_GLOBAL_NAME="^[A-Z][A-Z0-9_]*$"

    cli::export cli core
}

cli::core::self_test() {
    cli core type .group --self-test
    cli core variable .group --self-test
    cli core emit .group --self-test
}
