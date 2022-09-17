
cli::util::readmap::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Deserialize pairs of records from stdin into an associative array.

Description
    Deserialize an associatve array where keys and values encoded using
    printf %q, a key is separated from its value by whitesapce, and the pairs
    are separated from themselves a newline.

    The deserialized associative array is emitted to stdout using declare -p.

Arguments
    --name -n               : The name of the associative array. Default: RESULT.
EOF
    cat << EOF

Examples
    Create the set { 'a' 'b' 'c' }.
        ${CLI_COMMAND[@]} -emit <<< $'a\n\b\nc'
EOF
}

cli::util::readmap::main() {
    local NAME="$1"

    declare -A "${NAME}"

    local KEY VALUE
    while read -r KEY VALUE; do
        cli::util::readmap::add "${NAME}" "${KEY}" "${VALUE}"
    done
}

cli::util::readmap::add() {
    : ${arg_name=RESULT}
    : ${1?"Unexpected missing key."}
    : ${2?"Unexpected missing value."}

    declare -n ref=${arg_name}

    # deserialize key and value
    eval "set $1 $2"

    ref+=( [$1]=$2 )
}

cli::util::readmap::self_test() {
    ${CLI_COMMAND[@]} --name set < /dev/null \
    | assert::pipe_eq \
        'declare -A set'

    declare -A RESULT=( [a]=b [f]=g )
    printf '%q %q\n' a b f g \
    | ${CLI_COMMAND[@]} \
    | assert::pipe_eq \
        "$(declare -p RESULT)"

    declare -A RESULT=( [$'\n']=$'\t' )
    printf '%q %q\n' $'\n' $'\t' \
    | ${CLI_COMMAND[@]} \
    | assert::pipe_eq_exact \
        "$(declare -p RESULT)"

    declare -A RESULT=()
    ${CLI_COMMAND[@]} ---emit | source /dev/stdin
    cli::util::readmap "$'\n'" "$'\t'"
    assert::pipe_eq_exact < <(declare -p RESULT) \
        "declare -A RESULT=([\$'\n']=\$'\t' )"
}
