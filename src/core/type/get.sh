CLI_IMPORT=(
    "cli bash variable get-info"
    "cli core type resolve"
)

cli::core::type::get::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get the bash name of a user defined type.

Description
    Arguments \$1 is the type.

    Set REPLY to the bash name of a user defined type.

    Assert that the type is declared.
EOF
}

cli::core::type::get() {
    cli::core::type::resolve "${1-}"
    local TYPE_NAME="${REPLY}"

    cli::bash::variable::get_info "${TYPE_NAME}" || cli::assert \
        "Expected type '$@' to be declared as '${TYPE_NAME}', but actually not."

    REPLY="${TYPE_NAME}"
}

cli::core::type::get::self_test() {
    declare -A CLI_TYPE_VERSION=(
        [major]='integer'
        [minor]='integer'
    )
    diff <( ${CLI_COMMAND[@]} ---reply version ) - <<< 'CLI_TYPE_VERSION'
}
