
cli::sample::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::sample::main() {
    :
}

cli::sample::self_test() {
    cli sample kitchen-sink --self-test
    cli sample simple --self-test
    cli sample simplest --self-test
    cli sample recurse --self-test
}
