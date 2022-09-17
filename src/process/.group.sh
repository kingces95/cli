
cli::process::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::process::main() {
    : # special loader case; export nothing
}

cli::process::self_test() {
    cli process signal --self-test
    cli process get-info --self-test
    cli process tree --self-test
}
