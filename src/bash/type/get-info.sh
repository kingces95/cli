#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get the type of a bash variable.

Description
    Arguments \$1 is the name of a bash variable.

    Set predicates:

        REPLY_CLI_BASH_TYPE_IS_INTEGER
        REPLY_CLI_BASH_TYPE_IS_STRING
        REPLY_CLI_BASH_TYPE_IS_SCALER
        REPLY_CLI_BASH_TYPE_IS_ARRAY
        REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY
        REPLY_CLI_BASH_TYPE_IS_MAP
        REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP

    If integer or string then SCALER, otherwise not SCALER.

    If integer_array then ARRAY.

    If integer_map then MAP.

    REPLY are the set of normalized flags.
EOF
}

::cli::bash::type::get_info::inline() {
    local TYPE="${1-}"

    REPLY_CLI_BASH_TYPE_IS_INTEGER=false
    REPLY_CLI_BASH_TYPE_IS_STRING=false
    REPLY_CLI_BASH_TYPE_IS_SCALER=false
    REPLY_CLI_BASH_TYPE_IS_ARRAY=false
    REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY=false
    REPLY_CLI_BASH_TYPE_IS_MAP=false
    REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP=false

    case "${TYPE}" in
        '') 
            REPLY=
            REPLY_CLI_BASH_TYPE_IS_SCALER=true       
            REPLY_CLI_BASH_TYPE_IS_STRING=true ;;        
        'i') 
            REPLY=i
            REPLY_CLI_BASH_TYPE_IS_SCALER=true       
            REPLY_CLI_BASH_TYPE_IS_INTEGER=true ;;
        'a') 
            REPLY=a
            REPLY_CLI_BASH_TYPE_IS_ARRAY=true ;;        
        'A') 
            REPLY=A
            REPLY_CLI_BASH_TYPE_IS_MAP=true ;;        
        'Ai') ;& 'iA') 
            REPLY=Ai
            REPLY_CLI_BASH_TYPE_IS_MAP=true       
            REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP=true ;;        
        'ai') ;& 'ia') 
            REPLY=ai
            REPLY_CLI_BASH_TYPE_IS_ARRAY=true      
            REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY=true ;;        
        *) cli::assert "Unexpected type '$@'."    
    esac
}

cli::bash::type::get_info::self_test() {
    cli::assert::eval() { eval "$@" || cli::assert; }

    test() {
        local EXPECTED_TYPE="$1"
        shift

        [[ "${REPLY}" == "${EXPECTED_TYPE}" ]] \
            || cli::assert "${REPLY} != ${EXPECTED_TYPE}"

        for p in "$@"; do
            cli::assert::eval "\${REPLY_CLI_BASH_TYPE_IS_${p}}"
        done

        local -i EXPECTED_TRUE=$#
        local -i ACTUAL_TRUE=0
        if ${REPLY_CLI_BASH_TYPE_IS_INTEGER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_TYPE_IS_STRING}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_TYPE_IS_SCALER}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_TYPE_IS_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_TYPE_IS_MAP}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP}; then ACTUAL_TRUE+=1; fi 

        (( ACTUAL_TRUE == EXPECTED_TRUE )) || cli::assert
    }

    ${CLI_COMMAND[@]} --- ; test '' STRING SCALER
    ${CLI_COMMAND[@]} --- i; test i INTEGER SCALER
    ${CLI_COMMAND[@]} --- A; test A MAP
    ${CLI_COMMAND[@]} --- iA; test Ai INTEGER_MAP MAP
    ${CLI_COMMAND[@]} --- a; test a ARRAY
    ${CLI_COMMAND[@]} --- ia; test ai INTEGER_ARRAY ARRAY
}
