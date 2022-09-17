
cli::temp::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
EOF
}

cli::temp::main() {
    : # special loader case; export nothing
}

cli::temp::self_test() {
    cli temp dir --self-test
    cli temp fifo --self-test
    cli temp file --self-test
    cli temp remove --self-test
}
