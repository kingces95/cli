#!/usr/bin/env CLI_TOOL=cli bash-cli-part

cli::test_inline::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Test.
EOF
}

cli::test_inline() {
    echo 'Hello world!' "$@"
}
