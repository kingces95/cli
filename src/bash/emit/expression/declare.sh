
cli::bash::emit::expression::declare::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::declare() {
    echo -n "declare -${2:--} $1"
}

cli::bash::emit::expression::declare::self_test() {
    diff <( ${CLI_COMMAND[@]} -- VAR gA; echo ) - <<< $'declare -gA VAR'
    diff <( ${CLI_COMMAND[@]} -- VAR; echo ) - <<< $'declare -- VAR'
}
