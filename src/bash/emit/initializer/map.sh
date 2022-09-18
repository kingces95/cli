#! inline

CLI_IMPORT=(
    "cli bash emit block paren"
    "cli bash emit expression key-value"
    "cli bash map keys"
)

cli::bash::emit::initializer::map::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::initializer::map() {
    local MAP_NAME=$1
    local -n REF=${MAP_NAME?'Missing map variable name.'}

    cli::bash::map::keys ${MAP_NAME} \
        | while read; do
            local KEY="${REPLY}"
            local VALUE="${REF[$KEY]}"

            cli::bash::emit::expression::key_value "${KEY}" VALUE
            
            echo
        done | cli::bash::emit::block::paren
}

cli::bash::emit::initializer::map::self_test() {
    local -A MAP=([a]=0 )
    diff <( ${CLI_COMMAND[@]} -- MAP; echo ) - <<< $'(\n    [a]="0"\n)'
}
