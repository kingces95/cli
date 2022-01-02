#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash string literal 

cli::bash::emit::initializer::string::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::initializer::string() {
    [[ ${1:-} ]] || cli::assert 'Missing string variable name.'

    local -n REF=${1-}
    cli::bash::string::literal "${REF}"
    echo -n "${REPLY}"
}

cli::bash::emit::initializer::string::self_test() {
    local VALUE='a b c'
    diff <( ${CLI_COMMAND[@]} -- VALUE; echo ) - <<< $'"a b c"'
}
