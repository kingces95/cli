#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli bash emit indent"
)

cli::bash::emit::block::curly::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::block::curly() {
    echo -n "{"
    cli::bash::emit::indent $'\n'
    echo -n "}"
}

cli::bash::emit::block::curly::self_test() {
    diff <( ${CLI_COMMAND[@]} -- <<< block; echo ) - <<< $'{\n    block\n}'
}
