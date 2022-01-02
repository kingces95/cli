#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::dump::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copies stdin to a temporary file and echos the path to the file.
EOF
}

cli::dump::inline() {
    :
}

cli::self_test() {
    cli::source cli-assert
}
