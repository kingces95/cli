#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Join arguments with a possibly multi-character delimiter.

Description
    Argument \$1 is the name of the variable to return the result.
    Argument \$2 is a delimiter used to join the remaining arguments.

Examples
    ${CLI_COMMAND[@]} :: a b c
EOF
}

cli::bash::join::main() {
    ::cli::bash::join::inline "$@"
    echo "${REPLY}"
}

::cli::bash::join::inline() {
    local DELIMITER=${1?'Missing delimiter'}
    shift

    REPLY=""
    while (( $# > 0 )); do
        REPLY+="$1"
        shift

        if (( $# > 0 )); then 
            REPLY+="${DELIMITER}"
        fi
    done
}

cli::bash::join::self_test() {
    diff <(${CLI_COMMAND[@]} -- . a b c) - <<< 'a.b.c' || cli::assert
    diff <(${CLI_COMMAND[@]} -- .) - <<< '' || cli::assert
}
