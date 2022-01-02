#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::name::from_inline::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Split an bash inline function name into the corresponding command.

Description
    Give a bash function name delimited by :: and ending in ::inline,
    replace :: with space and dash with underbar except it it appears 
    after :: in which case convert it to period.

    Return the result in REPLY.
EOF
}

cli::name::from_inline::inline() {
    set -- "${1//::_/::.}"
    set -- "${1//_/-}"
    set -- ${1//::/ }
    [[ "${@: -1}" == 'inline' ]] \
        || cli::assert "Shim called from non-inline function ${FUNCNAME[1]}."

    REPLY=${@:1:$(( $# -1 ))}
}

cli::name::from_inline::self_test() {
    diff <(${CLI_COMMAND[@]} ---reply ::foo::foo_bar::_foo::inline) - \
        <<< 'foo foo-bar .foo' || cli::assert
}
