#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit expression declare

cli::bash::emit::statement::declare::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::statement::declare::inline() {
    cli::bash::emit::expression::declare::inline "$@"
    echo
}

cli::bash::emit::statement::declare::self_test() {
    diff <( ${CLI_COMMAND[@]} -- VAR gA  ) - <<< $'declare -gA VAR'
    diff <( ${CLI_COMMAND[@]} -- VAR ) - <<< $'declare -- VAR'
}
