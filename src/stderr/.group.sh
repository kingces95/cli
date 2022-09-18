
cli::stderr::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::stderr::main() {
    : # special loader case; export nothing
}

cli::stderr::self_test() {
    echo cli stderr cat --self-test
    cli stderr on-err --self-test
    cli stderr lock --self-test
    cli stderr message --self-test
    echo cli stderr dump --self-test
    echo cli stderr fail --self-test
    echo cli stderr assert --self-test
}
