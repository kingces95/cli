#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit indent
cli::source cli bash emit block curly

cli::bash::emit::function::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Assign REPLY with a bash literal of the first argument as would be returned by 
    'display -p' for a map key.
EOF
}

cli::bash::emit::function::inline() {
    echo -n "$1() "
    cli::bash::emit::block::curly::inline
    echo
}

cli::bash::emit::function::self_test() {
    diff <( ${CLI_COMMAND[@]} -- foo <<< ':' ) - <<< $'foo() {\n    :\n}'
}
