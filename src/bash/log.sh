#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::log::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Use echo to copy arguments to stderr.
EOF
}

cli::bash::log() {
    echo "$@" >&2
}

cli::bash::log::self_test() {
    diff <(${CLI_COMMAND[@]} -- a b c 2> /dev/null; echo) - <<< '' || cli::assert
    diff <(${CLI_COMMAND[@]} -- a b c 2>&1) - <<< 'a b c' || cli::assert
}
