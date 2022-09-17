
cli::core::variable::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
    resolve - given a variable, type, and fields, resolve the bash variable
    declare - initialize a variable with default values for all fields
    get/put - get or set a variable field's value
    read/write - read/write a variable's fields as records

EOF
}

cli::core::variable::main() {
    :
}

cli::core::variable::self_test() {
    cli core variable name .group --self-test
    cli core variable get-info --self-test
    cli core variable parse --self-test
    cli core variable resolve --self-test
    cli core variable write --self-test
    cli core variable save --self-test
    cli core variable load --self-test
    cli core variable initialize --self-test
    cli core variable get --self-test
    cli core variable declare --self-test
    cli core variable put --self-test
    cli core variable read --self-test
    cli core variable children --self-test
    cli core variable find --self-test
    cli core variable match --self-test
    cli core variable unset --self-test
}
