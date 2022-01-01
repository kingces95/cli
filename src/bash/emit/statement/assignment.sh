#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

::cli::bash::emit::statement::assignment::inline() {
    : ${1:-'Missing varaible.'}
    : ${2:-'Missing varaible.'}

    cat $1
    echo -n '='
    cat $2
    echo
}

cli::bash::emit::statement::assignment::self_test() {
    diff <( ${CLI_COMMAND[@]} -- <( echo -n VAR ) <( echo -n 42 ) ) - <<< $'VAR=42'
}
