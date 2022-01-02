#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash type get-info
cli::source cli bash variable declaration get-info

cli::bash::variable::get_info::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}

Summary
    Get the literal value of a bash variable as returned by declare -p.

Description
    Arguments \$1 is the name of a bash variable.

    Fail if the bash variable is undefined.
    
    The type is returned in REPLY and the following predicates are set:

        REPLY_CLI_BASH_VARIABLE_IS_INITIALIZED
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER
        REPLY_CLI_BASH_VARIABLE_IS_STRING
        REPLY_CLI_BASH_VARIABLE_IS_SCALER
        REPLY_CLI_BASH_VARIABLE_IS_ARRAY
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER_ARRAY
        REPLY_CLI_BASH_VARIABLE_IS_MAP
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER_MAP
        REPLY_CLI_BASH_VARIABLE_IS_READONLY
        REPLY_CLI_BASH_VARIABLE_IS_EXPORTED
        REPLY_CLI_BASH_VARIABLE_IS_UPPER
        REPLY_CLI_BASH_VARIABLE_IS_LOWER

        REPLY is the set of normalized flags for just the type without modifiers
        such as readonly.
EOF
}

::cli::bash::variable::get_info::inline() {
    # declare cache
    declare -gA CLI_BASH_VARIABLE_INFO_CACHE+=()
    REPLY_CLI_BASH_VARIABLE_IS_CACHE_HIT=false

    REPLY_CLI_BASH_VARIABLE_IS_INTEGER=false
    REPLY_CLI_BASH_VARIABLE_IS_STRING=false
    REPLY_CLI_BASH_VARIABLE_IS_SCALER=false
    REPLY_CLI_BASH_VARIABLE_IS_ARRAY=false
    REPLY_CLI_BASH_VARIABLE_IS_INTEGER_ARRAY=false
    REPLY_CLI_BASH_VARIABLE_IS_MAP=false
    REPLY_CLI_BASH_VARIABLE_IS_INTEGER_MAP=false
    REPLY_CLI_BASH_VARIABLE_IS_READONLY=false
    REPLY_CLI_BASH_VARIABLE_IS_EXPORTED=false
    REPLY_CLI_BASH_VARIABLE_IS_UPPER=false
    REPLY_CLI_BASH_VARIABLE_IS_LOWER=false
    REPLY_CLI_BASH_VARIABLE_IS_UNINITIALIZED=false

    local NAME="${1-}"
    [[ ${NAME} ]] || cli::assert 'Missing variable name.'

    # try readonly initialized cache
    if [[ ${CLI_BASH_VARIABLE_INFO_CACHE["${NAME}"]+set == "set" } ]]; then
        REPLY_CLI_BASH_VARIABLE_IS_READONLY=true
        REPLY_CLI_BASH_VARIABLE_IS_CACHE_HIT=true

        ::cli::bash::type::get_info::inline "${CLI_BASH_VARIABLE_INFO_CACHE["$1"]}"

        REPLY=${REPLY}
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER=${REPLY_CLI_BASH_TYPE_IS_INTEGER}
        REPLY_CLI_BASH_VARIABLE_IS_STRING=${REPLY_CLI_BASH_TYPE_IS_STRING}
        REPLY_CLI_BASH_VARIABLE_IS_SCALER=${REPLY_CLI_BASH_TYPE_IS_SCALER}
        REPLY_CLI_BASH_VARIABLE_IS_ARRAY=${REPLY_CLI_BASH_TYPE_IS_ARRAY}
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER_ARRAY=${REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY}
        REPLY_CLI_BASH_VARIABLE_IS_MAP=${REPLY_CLI_BASH_TYPE_IS_MAP}
        REPLY_CLI_BASH_VARIABLE_IS_INTEGER_MAP=${REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP}
        return
    fi

    local NEXT_NAME=$NAME
    while true; do

        # test declared
        local DECLARE
        DECLARE=$( declare -p ${NEXT_NAME} 2>/dev/null ) || return

        # type
        local _ FLAGS VALUE
        read _ FLAGS VALUE <<< "${DECLARE}"

        ::cli::bash::variable::declaration::get_info::inline "${FLAGS//-/}"
        
        # dereference name
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_NAMED}; then
            NEXT_NAME=$(eval "echo \${!${NEXT_NAME}}")
            continue
        fi

        # uninitialized
        if [[ "${VALUE}" == "${NEXT_NAME}" ]]; then
            REPLY_CLI_BASH_VARIABLE_IS_UNINITIALIZED=true
        fi

        break;
    done

    # populate cache if variable has a value and is strictly readonly
    if ! ${REPLY_CLI_BASH_VARIABLE_IS_UNINITIALIZED} &&
        ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY} &&
        ! ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED} &&
        ! ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER} &&
        ! ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER}; then

        CLI_BASH_VARIABLE_INFO_CACHE["${NAME}"]="${REPLY}"
    fi

    REPLY=${REPLY}
    REPLY_CLI_BASH_VARIABLE_IS_INTEGER=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER}
    REPLY_CLI_BASH_VARIABLE_IS_STRING=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_STRING}
    REPLY_CLI_BASH_VARIABLE_IS_SCALER=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_SCALER}
    REPLY_CLI_BASH_VARIABLE_IS_ARRAY=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_ARRAY}
    REPLY_CLI_BASH_VARIABLE_IS_INTEGER_ARRAY=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_ARRAY}
    REPLY_CLI_BASH_VARIABLE_IS_MAP=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_MAP}
    REPLY_CLI_BASH_VARIABLE_IS_INTEGER_MAP=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_MAP}
    REPLY_CLI_BASH_VARIABLE_IS_READONLY=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY}
    REPLY_CLI_BASH_VARIABLE_IS_EXPORTED=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED}
    REPLY_CLI_BASH_VARIABLE_IS_UPPER=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER}
    REPLY_CLI_BASH_VARIABLE_IS_LOWER=${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER}
}

cli::bash::variable::get_info::self_test() {
    cli::assert::eval() { eval "$@" || cli::assert; }

    test_flags() {
        local -i EXPECTED_TRUE=$#

        for p in "$@"; do
            cli::assert::eval "\${REPLY_CLI_BASH_VARIABLE_IS_${p}}"
        done

        local -i ACTUAL_TRUE=0
        if ${REPLY_CLI_BASH_VARIABLE_IS_INTEGER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_STRING}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_SCALER}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_MAP}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_INTEGER_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_INTEGER_MAP}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_IS_READONLY}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_EXPORTED}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_UPPER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_LOWER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_UNINITIALIZED}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_IS_CACHE_HIT}; then ACTUAL_TRUE+=1; fi

        if ! (( ACTUAL_TRUE == EXPECTED_TRUE )); then
            cli::dump 'REPLY_CLI_BASH_VARIABLE_IS_*' >&2
            cli::assert "${ACTUAL_TRUE} != ${EXPECTED_TRUE}"
        fi
    }

    test() {
        local EXPECTED=$1
        shift

        local NAME=$1
        shift

        ${CLI_COMMAND[@]} --- ${NAME}
        [[ "${EXPECTED}" == "${REPLY}" ]] \
            || cli::assert "${EXPECTED} != ${REPLY}"
        
        test_flags "$@"
    }

    ! ${CLI_COMMAND[@]} --- VAR || cli::assert

    local -- MY_STRING=; test '' MY_STRING STRING SCALER
    local -i MY_INTEGER=; test i MY_INTEGER INTEGER SCALER
    local -a MY_ARRAY=(); test a MY_ARRAY ARRAY
    local -A MY_MAP=(); test A MY_MAP MAP
    local -ia MY_IARRAY=(); test ai MY_IARRAY INTEGER_ARRAY ARRAY
    local -iA MY_IMAP=(); test Ai MY_IMAP INTEGER_MAP MAP 

    local -n MY_STRING_REF=MY_STRING; test '' MY_STRING_REF STRING SCALER
    local -n MY_STRING_REF_REF=MY_STRING_REF; test '' MY_STRING_REF_REF STRING SCALER

    local -- MY_USTRING; test '' MY_USTRING STRING SCALER UNINITIALIZED
    local -i MY_UINTEGER; test i MY_UINTEGER INTEGER SCALER UNINITIALIZED
    local -a MY_UARRAY; test a MY_UARRAY ARRAY UNINITIALIZED
    local -A MY_UMAP; test A MY_UMAP MAP UNINITIALIZED

    local -r MY_RO_STRING=; test '' MY_RO_STRING STRING SCALER READONLY
    local -ir MY_RO_INTEGER=; test i MY_RO_INTEGER INTEGER SCALER READONLY
    local -ar MY_RO_ARRAY=; test a MY_RO_ARRAY ARRAY READONLY
    local -Ar MY_RO_MAP=; test A MY_RO_MAP MAP READONLY
    local -ira MY_RO_IARRAY=(); test ai MY_RO_IARRAY INTEGER_ARRAY ARRAY READONLY
    local -iAr MY_RO_IMAP=(); test Ai MY_RO_IMAP INTEGER_MAP MAP READONLY

    test '' MY_RO_STRING STRING SCALER READONLY CACHE_HIT
    test i MY_RO_INTEGER INTEGER SCALER READONLY CACHE_HIT
    test a MY_RO_ARRAY ARRAY READONLY CACHE_HIT
    test A MY_RO_MAP MAP READONLY CACHE_HIT
    test ai MY_RO_IARRAY INTEGER_ARRAY ARRAY READONLY CACHE_HIT
    test Ai MY_RO_IMAP INTEGER_MAP MAP READONLY CACHE_HIT
}
