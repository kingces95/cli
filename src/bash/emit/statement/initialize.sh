#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit expression declare

cli::bash::emit::statement::initialize::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Emit a variable a declaration and initialization.

Description
    \$1 is the variable name.
    \$2 is the flags.

    The initializer is copied from stdin.
EOF
}

cli::bash::emit::statement::initialize::inline() {
    local NAME=${1-}
    [[ "${NAME}" ]] || cli::assert 'Missing name.'

    local FLAGS=${2-}

    # declare expression
    cli::bash::emit::expression::declare::inline ${NAME} ${FLAGS}
    
    # assignment statement
    echo -n '='

    # literal value
    cat
}

cli::bash::emit::statement::initialize::self_test() {

    diff <(${CLI_COMMAND[@]} -- MY_STRING <<< '"Hello world!"') - \
        <<< 'declare -- MY_STRING="Hello world!"'

    diff <(${CLI_COMMAND[@]} -- MY_ARRAY a <<< '()') - \
        <<< 'declare -a MY_ARRAY=()'
}