
cli::name::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::name::main() {
    : # special loader case; export nothing
}

cli::name::self_test() {
    cli name from-inline --self-test
    cli name parse --self-test
    cli name to-bash --self-test
    cli name to-inline --self-test
    cli name to-main --self-test
    cli name to-symbol --self-test
}
