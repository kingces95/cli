CLI_IMPORT=(
    "cli bash string literal"
)

cli::bash::key::literal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Assign REPLY with a bash literal of the first argument as would be returned by 
    'display -p' for a map key.
EOF
}

cli::bash::key::literal() {
    local LITERAL="$*"
    
    if [[ "${LITERAL}" =~ ^[a-zA-Z0-9_-]*$ ]]; then
        REPLY="${LITERAL}"
        return 0
    fi

    local -A MAP=( ["$*"]= )
    LITERAL=$(declare -p MAP)

    # 123456789012345678901
    # declare -A MAP=([hi]="" )
    LITERAL="${LITERAL:17}"
    LITERAL="${LITERAL:0: -6}"

    REPLY="${LITERAL}"
}

cli::bash::key::literal::self_test() {
    local -A HELLO_MAP=( [hello]= )
    local -A HELLO_WORLD_MAP=( ["hello world"]= )
    local -A BELL_MAP=( [$'\a']= )
    local -A MONEY_MAP=( ["\$"]= )

    diff <(${CLI_COMMAND[@]} ---reply hello) - <<< 'hello'
    diff <(${CLI_COMMAND[@]} ---reply 'hello world') - <<< '"hello world"'
    diff <(${CLI_COMMAND[@]} ---reply $'\a') - <<< "\$'\a'"
    diff <(${CLI_COMMAND[@]} ---reply '$') - <<< '"\$"'
}
