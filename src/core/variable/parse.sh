#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return type in MAPFILE and variable name in REPLY.

Description
    Positional arguments are the type followed by the variable name.

    Type names are lower case separated by underbars.
    The variable name must be uppercase separated by underbars.

    No semantic verification of the type is preformed.
EOF
}

cli::core::variable::parse::main() {
    ::cli::core::variable::parse::inline "$@"
    declare -p MAPFILE REPLY
}

::cli::core::variable::parse::inline() {
    local ARGS=( "$@" )
    MAPFILE=()

    (( $# >= 2 )) \
        || cli::assert "Failed to parse type name followed by global name in '${ARGS[@]}'."

    while [[ "${1-}" =~ ${CLI_CORE_REGEX_TYPE_NAME} ]]; do
        MAPFILE+=( "$1" )
        shift
    done

    [[ "${1-}" =~ ${CLI_CORE_REGEX_GLOBAL_NAME} ]] \
        || cli::assert "Failed to parse type name followed by global name in '${ARGS[@]}'."

    REPLY="$1"
}

cli::core::variable::parse::self_test() {
    diff <(${CLI_COMMAND[@]} -- string VAR) - \
        <<< $'declare -a MAPFILE=([0]=\"string\")\ndeclare -- REPLY=\"VAR\"' || cli::assert
    return
}
