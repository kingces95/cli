
cli::attribute::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::attribute::main() {
    : # special loader case; export nothing
}

cli::attribute::self_test() {
    cli attribute is-defined --self-test
}
