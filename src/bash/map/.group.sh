
cli::bash::map::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
EOF
}

cli::bash::map::main() {
    :
}

cli::bash::map::self_test() {
    cli bash map copy --self-test
    cli bash map keys --self-test
    cli bash map literal --self-test
}
