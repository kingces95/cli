#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::core::type::resolve::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get the bash name of a user defined type.

Description
    Arguments \$1 is the type.

    Set REPLY to the bash name of a user defined type.
EOF
}

cli::core::type::resolve::inline() {
    local TYPE="${1-}"

    [[ "${TYPE}" =~ $CLI_CORE_REGEX_TYPE_NAME ]] \
        || cli::assert "Expected type name to match '${CLI_CORE_REGEX_TYPE_NAME}', but got '${TYPE}'."

    REPLY="CLI_TYPE_${TYPE^^}"
}

cli::core::type::resolve::self_test() {
    diff <( ${CLI_COMMAND[@]} ---reply udt ) - <<< 'CLI_TYPE_UDT'
}
