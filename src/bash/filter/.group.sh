
cli::bash::filter::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description

EOF
}

cli::bash::filter::main() {
    : # special loader case; export nothing
}

cli::bash::filter::self_test() {
    cli bash filter glob --self-test
}
