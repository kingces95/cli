#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli bash emit indent"
)

cli::bash::emit::block::paren::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::block::paren() {
    echo -n "("
    cli::bash::emit::indent $'\n'
    echo -n ")"
}

cli::bash::emit::block::paren::self_test() {
    diff <( ${CLI_COMMAND[@]} -- <<< block; echo ) - <<< $'(\n    block\n)'
}
