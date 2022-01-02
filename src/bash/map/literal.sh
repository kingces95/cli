#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash key literal
cli::source cli bash string literal

cli::bash::map::literal::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Set REPLY to a bash literal representing the sorted key/value pairs
    of a map of the same format as would be returned by 'declare -p'.

Details
    Positional arguments are keys to a map whose name is set to ARG_MAP.
    The keys are sorted after being converted to literal key values. 
EOF
}

cli::bash::map::literal::inline() {
    local -n MAP_REF=${ARG_MAP}

    local LITERAL=( '(' )

    while (( $# > 0 )); do
        cli::bash::key::literal::inline "$1"
        echo "${REPLY}"
        shift
    done \
    | sort \
    | while read -r REPLY; do
        LITERAL+=( "[" )
        LITERAL+=( "${REPLY}" )
        LITERAL+=( "]=" )
        cli::bash::string::literal::inline "${MAP_REF["$1"]}"
        LITERAL+=( "${REPLY}" )
        LITERAL+=( ' ' )
    done

    LITERAL+=( ')' )

    IFS=
    REPLY="${LITERAL[*]}"
    IFS=${CLI_IFS}
}

cli::bash::map::literal::self_test() {
    local -A HELLO_MAP=( [hi]='hello' )
    local -A HELLO_WORLD_MAP=( ['the key']='hello world' )
    local -A BELL_MAP=( [$'\n']=$'\a' )
    local -A MONEY_MAP=( ['$key']="\$" )
    local -A SORT_MAP=( [b]= [a]= [d]= [c]= )

    diff <(ARG_MAP=HELLO_MAP ${CLI_COMMAND[@]} ---reply "${!HELLO_MAP[@]}") \
        - <<< "([hi]=\"hello\" )"

    diff <(ARG_MAP=HELLO_WORLD_MAP ${CLI_COMMAND[@]} ---reply "${!HELLO_WORLD_MAP[@]}") \
        - <<< "([\"the key\"]=\"hello world\" )"

    diff <(ARG_MAP=BELL_MAP ${CLI_COMMAND[@]} ---reply "${!BELL_MAP[@]}") \
        - <<< "([$'\n']=\$'\a' )"
    
    diff <(ARG_MAP=MONEY_MAP ${CLI_COMMAND[@]} ---reply "${!MONEY_MAP[@]}") \
        - <<< "([\"\\\$key\"]=\"\\\$\" )"

    diff <(ARG_MAP=SORT_MAP ${CLI_COMMAND[@]} ---reply "${!SORT_MAP[@]}") \
        - <<< '([a]="" [b]="" [c]="" [d]="" )'
}
