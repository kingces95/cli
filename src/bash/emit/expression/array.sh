#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash emit block paren 
cli::source cli bash emit expression key-value 

cli::bash::emit::expression::array::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::expression::array() {
    local NAME="$1"
    local -n REF=${1?'Missing map variable name.'}

    local INDEX
    for (( INDEX=0; INDEX < ${#REF[@]}; INDEX++ )); do
        local VALUE="${REF[$INDEX]}"

        cli::bash::emit::expression::key_value "${INDEX}" VALUE
        
        echo
    done | cli::bash::emit::block::paren
}

cli::bash::emit::expression::array::self_test() {
    local ARR=(a)
    diff <( ${CLI_COMMAND[@]} -- ARR; echo ) - <<< $'(\n    [0]="a"\n)'
}
