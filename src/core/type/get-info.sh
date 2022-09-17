
cli::core::type::get_info::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get type information.

Description
    Arguments \$1 - \$n represent a type.

    Set REPLY to the name of a user defined type or empty or
    empty if the type is modified or builtin.

    Set predicates:

        REPLY_CLI_CORE_TYPE_IS_INTEGER
        REPLY_CLI_CORE_TYPE_IS_BOOLEAN
        REPLY_CLI_CORE_TYPE_IS_STRING
        REPLY_CLI_CORE_TYPE_IS_SCALER
        REPLY_CLI_CORE_TYPE_IS_BUILTIN
        REPLY_CLI_CORE_TYPE_IS_ARRAY
        REPLY_CLI_CORE_TYPE_IS_MAP
        REPLY_CLI_CORE_TYPE_IS_MODIFIED
        REPLY_CLI_CORE_TYPE_IS_USER_DEFINED

    If type type is modified, then all the above predicates are false,
    predicate REPLY_CLI_CORE_TYPE_IS_MODIFIED is true, and array
    MAPFILE contains the unmodified type.

    If type is umodified then MAPFILE contains a copy of the type.
EOF
}

cli::core::type::get_info() {
    MAPFILE=( "$@" )
    REPLY="${MAPFILE[@]}"

    # cache
    if [[ "${REPLY_CLI_CORE_TYPE-}" == "${REPLY}" ]]; then
        return
    fi
    REPLY_CLI_CORE_TYPE="$@"

    REPLY_CLI_CORE_TYPE_IS_INTEGER=false
    REPLY_CLI_CORE_TYPE_IS_BOOLEAN=false
    REPLY_CLI_CORE_TYPE_IS_STRING=false
    REPLY_CLI_CORE_TYPE_IS_SCALER=false
    REPLY_CLI_CORE_TYPE_IS_BUILTIN=false
    REPLY_CLI_CORE_TYPE_IS_ARRAY=false
    REPLY_CLI_CORE_TYPE_IS_MAP=false
    REPLY_CLI_CORE_TYPE_IS_MODIFIED=false
    REPLY_CLI_CORE_TYPE_IS_USER_DEFINED=false

    # modified
    while [[ "${MAPFILE}" == 'map_of' ]]; do
        REPLY_CLI_CORE_TYPE_IS_MODIFIED=true
        return
    done

    # scaler
    while true; do
        case "${MAPFILE}" in
            'string') REPLY_CLI_CORE_TYPE_IS_STRING=true ;;
            'integer') REPLY_CLI_CORE_TYPE_IS_INTEGER=true ;;
            'boolean') REPLY_CLI_CORE_TYPE_IS_BOOLEAN=true ;;
            *) break    
        esac

        REPLY_CLI_CORE_TYPE_IS_BUILTIN=true
        REPLY_CLI_CORE_TYPE_IS_SCALER=true       
        return
    done

    # indexable
    while true; do
        case "${MAPFILE}" in
            'array') REPLY_CLI_CORE_TYPE_IS_ARRAY=true ;;        
            'map') REPLY_CLI_CORE_TYPE_IS_MAP=true ;;        
            *) break    
        esac

        REPLY_CLI_CORE_TYPE_IS_BUILTIN=true
        return
    done

    # user defined
    [[ "${MAPFILE}" =~ ${CLI_CORE_REGEX_TYPE_NAME} ]] \
        || cli::assert "Expected type name to match '${CLI_CORE_REGEX_TYPE_NAME}', but got '${MAPFILE}'."

    REPLY_CLI_CORE_TYPE_IS_USER_DEFINED=true
}

cli::core::type::get_info::self_test() {
    cli::assert::eval() { eval "$@" || cli::assert; }

    test() {
        local -i EXPECTED=$#
        for p in "$@"; do
            cli::assert::eval "\${REPLY_CLI_CORE_TYPE_IS_${p}}"
        done

        local -i ACTUAL=0
        if ${REPLY_CLI_CORE_TYPE_IS_INTEGER}; then ACTUAL+=1; fi
        if ${REPLY_CLI_CORE_TYPE_IS_BOOLEAN}; then ACTUAL+=1; fi
        if ${REPLY_CLI_CORE_TYPE_IS_STRING}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_SCALER}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_ARRAY}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_MAP}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_BUILTIN}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_MODIFIED}; then ACTUAL+=1; fi 
        if ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED}; then ACTUAL+=1; fi 

        [[ "${REPLY}" == "${MAPFILE[*]}" ]] || cli::assert
        [[ "${REPLY}" ]] || cli::assert

        (( ${#MAPFILE[@]} > 0 )) || cli::assert
        if ! (( ACTUAL == EXPECTED )); then
            cli::dump 'REPLY_CLI_CORE_TYPE_IS_*' >&2
            cli::assert "actual ${ACTUAL} != expected ${EXPECTED}"
        fi
    }

    diff <( ${CLI_COMMAND[@]} ---reply udt; test USER_DEFINED ) - <<< 'udt'
    diff <( ${CLI_COMMAND[@]} ---reply string; test STRING SCALER BUILTIN ) - <<< 'string'
    diff <( ${CLI_COMMAND[@]} ---reply boolean; test BOOLEAN SCALER BUILTIN ) - <<< 'boolean'
    diff <( ${CLI_COMMAND[@]} ---reply integer; test INTEGER SCALER BUILTIN ) - <<< 'integer'
    diff <( ${CLI_COMMAND[@]} ---reply map; test MAP BUILTIN ) - <<< 'map'
    diff <( ${CLI_COMMAND[@]} ---reply array; test ARRAY BUILTIN ) - <<< 'array'
    diff <( ${CLI_COMMAND[@]} ---reply map_of udt; test MODIFIED ) - <<< 'map_of udt'
    
    diff <( ${CLI_COMMAND[@]} ---mapfile map_of udt ) - <<< $'map_of\nudt'
    diff <( ${CLI_COMMAND[@]} ---mapfile map_of map_of udt ) - <<< $'map_of\nmap_of\nudt'
}
