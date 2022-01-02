#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::util::readset::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Read stdin into an associative array.

Description
    Declare a set represented an associative where each value is 
    'true' and each key is read from stdin.

Arguments
    --name -n               : The name of the associative array. Default: RESULT.
EOF
    cat << EOF

Examples
    Create the set { 'a' 'b' 'c' }.
        ${CLI_COMMAND[@]} -emit <<< $'a\n\b\nc'
EOF
}

cli::util::readset::inline() {
    : ${arg_name=RESULT}

    declare -n ref=${arg_name}

    while read -r; do
        eval "ref+=( [$REPLY]=true )"
    done
}

cli::util::readset::main() {
    declare -A ${arg_name}
    inline
    declare -p ${arg_name}
}

cli::util::readset::self_test() {
    # cat /dev/null \
    # | ${CLI_COMMAND[@]} --name set \
    # | assert::pipe_eq \
    #     'declare -A set'

    # ${CLI_COMMAND[@]} --name set <<< $'a' \
    # | assert::pipe_eq \
    #     'declare -A set=([a]="true" )'

    printf '%q\n' $'\n' \
    | ${CLI_COMMAND[@]} --name set
    # | assert::pipe_eq \
    #     'declare -A set=([a]="true" )'
    
    return

    ${CLI_COMMAND[@]} --name set <<< $'a\nb' \
    | assert::pipe_eq \
        'declare -A set=([b]="true" [a]="true" )'

    declare -A RESULT
    ${CLI_COMMAND[@]} ---emit | source /dev/stdin
    ::cli::util::readset::inline <<< $'a'
    assert::pipe_eq < <(declare -p RESULT) \
        'declare -A RESULT=([a]="true" )'
}
