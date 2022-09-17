
cli::bash::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description

EOF
}

cli::bash::main() {
    : # special loader case; export nothing
}

cli::bash::self_test() {
    cli bash array .group --self-test
    cli bash emit .group --self-test
    cli bash key .group --self-test
    cli bash map .group --self-test
    cli bash stack .group --self-test
    cli bash string .group --self-test
    cli bash type .group --self-test
    cli bash variable .group --self-test
    cli bash function .group --self-test
    cli bash filter .group --self-test
    cli bash group --self-test
    cli bash join --self-test
    cli bash literal --self-test
    cli bash log --self-test
    cli bash return --self-test
    cli bash which --self-test
    cli bash write --self-test
}
