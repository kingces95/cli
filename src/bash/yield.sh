#!/usr/bin/env CLI_TOOL=cli bash-cli-part

cli::bash::yield::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Echo each argument to stdout.

Description
    Argument \$1 - \$n are the arguments to copy to stdout.
EOF
}

cli::bash::yield() {
    while (( $# > 0 )); do
        echo "$1"
        shift
    done
}

cli::bash::yield::self_test() {
    diff <(${CLI_COMMAND[@]} --) - < /dev/null || cli::assert
    diff <(${CLI_COMMAND[@]} -- a b c) - <<< $'a\nb\nc' || cli::assert
}
