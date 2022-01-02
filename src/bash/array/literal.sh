#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::array::literal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return arguments as a bash literal array in REPLY.
EOF
}

::cli::bash::array::literal::inline() {
    local ARRAY=( "$@" )
    local LITERAL=$(declare -p ARRAY)

    # 0123456789012345678901
    # declare -a ARRAY=([0]="foo")
    REPLY="${LITERAL:17}"
}

cli::bash::array::literal::self_test() {
    local HELLO=( hello )
    local HELLO_WORLD=( hello world )
    local BELL=( $'\a' )
    local MONEY=( "\$" )

    diff <(${CLI_COMMAND[@]} ---reply ${HELLO[@]}) - <<< '([0]="hello")'
    diff <(${CLI_COMMAND[@]} ---reply ${HELLO_WORLD[@]}) - <<< '([0]="hello" [1]="world")'
    diff <(${CLI_COMMAND[@]} ---reply ${BELL[@]}) - <<< "([0]=\$'\a')"
    diff <(${CLI_COMMAND[@]} ---reply ${MONEY[@]}) - <<< "([0]=\"\\\$\")"
}
