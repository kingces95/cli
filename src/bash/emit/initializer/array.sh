CLI_IMPORT=(
    "cli bash emit block paren"
    "cli bash emit initializer string"
)

cli::bash::emit::initializer::array::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
EOF
}

cli::bash::emit::initializer::array() {
    local NAME="$1"
    local -n REF=${1?'Missing map variable name.'}

    local INDEX
    for (( INDEX=0; INDEX < ${#REF[@]}; INDEX++ )); do
        local VALUE="${REF[$INDEX]}"

        cli::bash::emit::initializer::string VALUE
        
        echo
    done | cli::bash::emit::block::paren
}

cli::bash::emit::initializer::array::self_test() {
    local ARR=(a)
    diff <( ${CLI_COMMAND[@]} -- ARR; echo ) - <<< $'(\n    "a"\n)'
}
