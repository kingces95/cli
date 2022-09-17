
cli::bash::literal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print a string as a literal bash string.

Description
    Positional argumetns are join using IFS and the result is copied to stdout
    as a bash literal string.

    Simple strings consisting of letters, numbers, dash, and underbar are
    printed as is. Otherwise, the bash string is harvested from 'declare -p'
    for the value of an array element. So spaces are wrapped in double quoes,
    the 'bell' character is printed as $'\a' and the dollar symbol as "\$".

Examples
    ${CLI_COMMAND[@]} -- hello
    ${CLI_COMMAND[@]} -- hello world
    ${CLI_COMMAND[@]} -- \$
EOF
}

cli::bash::literal() {
    local literal="$*"
    
    if [[ "${literal}" =~ ^[a-zA-Z0-9_-]*$ ]]; then
        echo "${literal}"
        return 0
    fi

    local ARRAY=( "$*" )
    literal=$(declare -p ARRAY)

    # 0123456789012345678901
    # declare -a ARRAY=([0]="foo")
    literal="${literal:22}"
    literal="${literal:0: -1}"

    echo "${literal}"
}

cli::bash::literal::self_test() {
    diff <(${CLI_COMMAND[@]} -- hello) - <<< 'hello' || cli::assert
    diff <(${CLI_COMMAND[@]} -- hello world) - <<< '"hello world"' || cli::assert
    diff <(${CLI_COMMAND[@]} -- $'\a') - <<< "\$'\\a'" || cli::assert
    diff <(${CLI_COMMAND[@]} -- "\$") - <<< '"\$"' || cli::assert
}
