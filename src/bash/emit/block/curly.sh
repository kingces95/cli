#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit indent

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

::cli::bash::emit::block::curly::inline() {
    echo -n "{"
    ::cli::bash::emit::indent::inline $'\n'
    echo -n "}"
}

cli::bash::emit::block::curly::self_test() {
    diff <( ${CLI_COMMAND[@]} -- <<< block; echo ) - <<< $'{\n    block\n}'
}