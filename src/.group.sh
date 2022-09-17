
cli::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description

EOF
}

cli::main() {
    : # special loader case; export nothing
}

cli::self_test() {
    
    cli args .group --self-test 
    cli attribute .group --self-test
    cli bash .group --self-test
    cli cache .group --self-test
    cli core .group --self-test 
    cli dsl .group --self-test 
    # cli import .group --self-test 
    cli name .group --self-test
    cli path .group --self-test
    cli process .group --self-test
    cli set .group --self-test
    cli shim .group --self-test
    cli stderr .group --self-test
    cli subshell .group --self-test
    cli temp .group --self-test
}
