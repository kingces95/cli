
cli::path::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::path::main() {
    : # special loader case; export nothing
}

cli::path::self_test() {
    cli path dir --self-test
    cli path name --self-test
    cli path make-absolute --self-test
    cli path make-relative --self-test
}
