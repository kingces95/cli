
cli::name::from_inline::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Split an bash inline function name into the corresponding command.

Description
    Give a bash function name return a command. 

    Return the result in REPLY.
EOF
}

cli::name::from_inline() {
    set -- "${1//::_/::.}"
    set -- "${1//_/-}"
    set -- ${1//::/ }
    # [[ "${@: -1}" == 'inline' ]] \
    #     || cli::assert "Shim called from non-inline function ${FUNCNAME[1]}."

    REPLY=$@
}

cli::name::from_inline::self_test() {
    diff <(${CLI_COMMAND[@]} ---reply ::foo::foo_bar::_foo) - \
        <<< 'foo foo-bar .foo' || cli::assert
}
