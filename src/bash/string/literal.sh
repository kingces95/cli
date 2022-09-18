#! inline

cli::bash::string::literal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return a string as a literal bash string in REPLY.

Description
    Argument \$1 is the string to return as a bash literal.
EOF
}

cli::bash::string::literal() {
    local LITERAL="$*"
    
    if [[ "${LITERAL}" =~ ^[a-zA-Z0-9_-]*$ ]]; then
        REPLY="\"${LITERAL}\""
        return 0
    fi

    local ARRAY=( "$*" )
    LITERAL=$(declare -p ARRAY)

    # 0123456789012345678901
    # declare -a ARRAY=([0]="foo")
    LITERAL="${LITERAL:22}"
    LITERAL="${LITERAL:0: -1}"

    REPLY="${LITERAL}"
}

cli::bash::string::literal::self_test() {
    diff <(${CLI_COMMAND[@]} ---reply hello) - <<< '"hello"'
    diff <(${CLI_COMMAND[@]} ---reply hello world) - <<< '"hello world"'
    diff <(${CLI_COMMAND[@]} ---reply $'\a') - <<< "\$'\\a'"
    diff <(${CLI_COMMAND[@]} ---reply "\$") - <<< '"\$"'
}
