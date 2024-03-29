#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli bash emit block paren"
    "cli bash emit expression key-value"
    "cli bash map keys"
)

cli::bash::emit::expression::map::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::map() {
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

cli::bash::emit::expression::map::self_test() {
    local -A MAP=([a]=0 )
    diff <( ${CLI_COMMAND[@]} -- MAP; echo ) - <<< $'(\n    [a]="0"\n)'
}
