#! inline

cli::bash::write::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Writes a record escaping default IFS characters; Opposite of 'read'.

Description
    Tables consist of records which are lines containing fields separated by
    whilespace found in IFS which have whitespace contained within them
    (plus backslash) escaped with a backslash. This function accepts a set
    of arguments, and prints a record consisting of those arguments.

    This operationn is the inverse of 'read' with default IFS; A record written
    with 'write' can be read with 'read' using the default value of IFS.

    This is different than print '%q' which is the inverse of eval and has a
    different set of escaping rules. 
EOF
}

cli::bash::write() {
    MAPFILE=()
    local COUNT=$#

    while (( $# > 0 )); do
        local field="$1"

        if [[ ! "${field}" ]]; then
            IFS=
            [[ ! "$*" ]] || cli::assert \
                "Arguments to write must not be empty unless they all appear last."
            IFS="${CLI_IFS}"
            break
        fi

        field="${field//\\/\\\\}"
        field="${field// /\\ }"
        field="${field//$'\t'/\\$'\t'}"

        MAPFILE+=( "${field}" )
        shift
    done

    echo "${MAPFILE[@]}"
}

cli::bash::write::self_test() {
    diff <(${CLI_COMMAND[@]} -- ) - <<< ''
    diff <(${CLI_COMMAND[@]} -- '' ) - <<< ''

    diff <(${CLI_COMMAND[@]} -- 'x' $' ' $'\t' '\' | read -a ARRAY; declare -p ARRAY) \
        - <<< "declare -a ARRAY=([0]=\"x\" [1]=\" \" [2]=\$'\t' [3]=\"\\\\\")"

    diff <(${CLI_COMMAND[@]} -- $'\a' | read -a ARRAY; declare -p ARRAY) \
        - <<< "declare -a ARRAY=([0]=\$'\a')"

    diff <(${CLI_COMMAND[@]} -- 'a b' | read -a ARRAY; declare -p ARRAY) \
        - <<< "declare -a ARRAY=([0]=\"a b\")"

    diff <(${CLI_COMMAND[@]} -- a '') - <<< $'a'
}
