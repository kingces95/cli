
cli::set::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::set::main() {
    : # special loader case; export nothing
}

cli::set::self_test() {
    cli set deflower --self-test
    cli set intersect --self-test
    cli set test --self-test
}
