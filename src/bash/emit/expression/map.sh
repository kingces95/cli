#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit block paren 
cli::source cli bash emit expression key-value 
cli::source cli bash map keys

cli::bash::emit::expression::map::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

::cli::bash::emit::expression::map::inline() {
    local MAP_NAME=$1
    local -n REF=${MAP_NAME?'Missing map variable name.'}

    ::cli::bash::map::keys::inline ${MAP_NAME} \
        | while read; do
            local KEY="${REPLY}"
            local VALUE="${REF[$KEY]}"

            ::cli::bash::emit::expression::key_value::inline "${KEY}" VALUE
            
            echo
        done | ::cli::bash::emit::block::paren::inline
}

cli::bash::emit::expression::map::self_test() {
    local -A MAP=([a]=0 )
    diff <( ${CLI_COMMAND[@]} -- MAP; echo ) - <<< $'(\n    [a]="0"\n)'
}
