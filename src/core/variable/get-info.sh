#! inline

CLI_IMPORT=(
    "cli core type get-info"
)

cli::core::variable::get_info::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get the type of a variable.

Description
    Arguments \$1 is the name of the variable.

    Fail if the variable is undefined.
    
    The type is returned in REPLY.
    
    The following predicates are set:

        REPLY_CLI_CORE_VARIABLE_IS_INTEGER
        REPLY_CLI_CORE_VARIABLE_IS_BOOLEAN
        REPLY_CLI_CORE_VARIABLE_IS_STRING
        REPLY_CLI_CORE_VARIABLE_IS_SCALER
        REPLY_CLI_CORE_VARIABLE_IS_ARRAY
        REPLY_CLI_CORE_VARIABLE_IS_MAP
        REPLY_CLI_CORE_VARIABLE_IS_BUILTIN
        REPLY_CLI_CORE_VARIABLE_IS_MODIFIED
        REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED
EOF
}

cli::core::variable::get_info() {
    local NAME="${1-}"
    [[ "${NAME}" ]] || cli::assert 'Missing variable name.'
    [[ "${NAME}" =~ ${CLI_REGEX_GLOBAL_NAME} ]] \
        || cli::assert "Bad variable name '${NAME}'."

    local SCOPE_NAME="${ARG_SCOPE}"
    [[ "${SCOPE_NAME}" ]] || cli::assert 'Missing scope.'

    local -n SCOPE_REF="${SCOPE_NAME}"
    if [[ ! "${SCOPE_REF["${NAME}"]+set}" == 'set' ]]; then
        return 1
    fi

    local TYPE="${SCOPE_REF["${NAME}"]}"
    [[ ${TYPE} ]] || cli::assert

    cli::core::type::get_info ${TYPE}
    REPLY_CLI_CORE_VARIABLE_IS_INTEGER=${REPLY_CLI_CORE_TYPE_IS_INTEGER}
    REPLY_CLI_CORE_VARIABLE_IS_BOOLEAN=${REPLY_CLI_CORE_TYPE_IS_BOOLEAN}
    REPLY_CLI_CORE_VARIABLE_IS_STRING=${REPLY_CLI_CORE_TYPE_IS_STRING}
    REPLY_CLI_CORE_VARIABLE_IS_SCALER=${REPLY_CLI_CORE_TYPE_IS_SCALER}
    REPLY_CLI_CORE_VARIABLE_IS_ARRAY=${REPLY_CLI_CORE_TYPE_IS_ARRAY}
    REPLY_CLI_CORE_VARIABLE_IS_MAP=${REPLY_CLI_CORE_TYPE_IS_MAP}
    REPLY_CLI_CORE_VARIABLE_IS_BUILTIN=${REPLY_CLI_CORE_TYPE_IS_BUILTIN}
    REPLY_CLI_CORE_VARIABLE_IS_MODIFIED=${REPLY_CLI_CORE_TYPE_IS_MODIFIED}
    REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED=${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED}
}

cli::core::variable::get_info::self_test() {
    cli::assert::eval() { eval "$@" || cli::assert; }

    test_flags() {
        local -i EXPECTED_TRUE=$#

        for p in "$@"; do
            cli::assert::eval "\${REPLY_CLI_CORE_VARIABLE_IS_${p}}"
        done

        local -i ACTUAL_TRUE=0
        if ${REPLY_CLI_CORE_VARIABLE_IS_INTEGER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_CORE_VARIABLE_IS_STRING}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_CORE_VARIABLE_IS_BOOLEAN}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_CORE_VARIABLE_IS_SCALER}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_CORE_VARIABLE_IS_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_CORE_VARIABLE_IS_MAP}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_CORE_VARIABLE_IS_BUILTIN}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED}; then ACTUAL_TRUE+=1; fi

        if ! (( ACTUAL_TRUE == EXPECTED_TRUE )); then
            cli::dump 'REPLY_CLI_CORE_VARIABLE_IS_*' >&2
            cli::assert "${ACTUAL_TRUE} != ${EXPECTED_TRUE}"
        fi
    }

    test() {
        local EXPECTED=$1
        shift

        local NAME=$1
        shift

        ${CLI_COMMAND[@]} --- ${NAME}
        # declare -p MAPFILE >&2
        # TODO MAPFILE should contain modified type not unmodified type
        [[ "${EXPECTED}" == "${REPLY}" ]] \
            || cli::assert "For '${NAME}', expected != actual; '${EXPECTED}' != '${REPLY}'"
        
        test_flags "$@"
    }

    local -A SCOPE=()
    local ARG_SCOPE='SCOPE'

    ! ${CLI_COMMAND[@]} -- VAR || cli::assert

    SCOPE['MY_STRING']='string'; test string MY_STRING STRING SCALER BUILTIN
    SCOPE['MY_BOOLEAN']='boolean'; test boolean MY_BOOLEAN BOOLEAN SCALER BUILTIN
    SCOPE['MY_INTEGER']='integer'; test integer MY_INTEGER INTEGER SCALER BUILTIN
    SCOPE['MY_ARRAY']='array'; test array MY_ARRAY ARRAY BUILTIN
    SCOPE['MY_MAP']='map'; test map MY_MAP MAP BUILTIN
    SCOPE['MY_UDT']='udt'; test udt MY_UDT USER_DEFINED
    SCOPE['MY_MODIFIED']='map_of string'; test 'map_of string' MY_MODIFIED MODIFIED
}
