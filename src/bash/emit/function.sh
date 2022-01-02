#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli bash emit block curly"
    "cli bash emit indent"
)

cli::bash::emit::function::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Assign REPLY with a bash literal of the first argument as would be returned by 
    'display -p' for a map key.
EOF
}

cli::bash::emit::function() {
    echo -n "$1() "
    cli::bash::emit::block::curly
    echo
}

cli::bash::emit::function::self_test() {
    diff <( ${CLI_COMMAND[@]} -- foo <<< ':' ) - <<< $'foo() {\n    :\n}'
}
