CLI_IMPORT=(
    "cli core type get"
    "cli core type get-info"
    "cli core type unmodified"
)

cli::core::type::emit::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Emit the name of all user defined types used to compose a type.
    
Description
    Argument \$1 is the type.

    Echo the name of all user defined types encountered by walking
    the type and its fields recursively. 
EOF
}

cli::core::type::emit() {

    # strip modifiers 
    cli::core::type::unmodified "$@"
    [[ "${REPLY}" ]] || cli::assert "Failed to unmodify '$@'.".

    # skip builtin types
    cli::core::type::get_info "${REPLY}"
    if ${REPLY_CLI_CORE_TYPE_IS_BUILTIN}; then
        return
    fi

    # emit the user defined type
    echo "${REPLY}"

    # recurse using the type of each of the user defined type's fields
    cli::core::type::get ${REPLY}
    local -n CLI_TYPE_REF="${REPLY}"
    for FIELD_TYPE in "${CLI_TYPE_REF[@]}"; do
        cli::core::type::emit ${FIELD_TYPE}
    done
}

cli::core::type::emit::self_test() {
    diff <( ${CLI_COMMAND[@]} -- string ) - < /dev/null
    diff <( ${CLI_COMMAND[@]} -- integer ) - < /dev/null
    diff <( ${CLI_COMMAND[@]} -- map ) - < /dev/null
    diff <( ${CLI_COMMAND[@]} -- array ) - < /dev/null
    diff <( ${CLI_COMMAND[@]} -- map_of string ) - < /dev/null
    diff <( ${CLI_COMMAND[@]} -- map_of map_of string ) - < /dev/null

    declare -A CLI_TYPE_FLOAT=(
        [decimal]="integer" 
        [places]="integer" 
        [integer]="integer"
    )

    diff <( ${CLI_COMMAND[@]} -- map_of float ) - <<< 'float'

    declare -A CLI_TYPE_CONSTANT=(
        [value]="float" 
        [alt]="float" 
        [name]="string"
    )

    diff <( ${CLI_COMMAND[@]} -- constant | sort -u ) - <<< $'constant\nfloat'
}
