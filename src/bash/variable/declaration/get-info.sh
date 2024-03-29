#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli bash type get-info"
)

cli::bash::variable::declaration::get_info::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Given flags as used by declare return a type.

Description
    Arguments \$1 is a set of flags of the form 
    
        (r?)[|i|b|a|A]

    The type is returned in REPLY and the following predicates are set:

        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_STRING
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_SCALER
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_ARRAY
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_ARRAY
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_MAP
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_MAP

        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_NAMED
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER

        REPLY is the set of normalized flags for just the type without modifiers
        such as readonly.
EOF
}

cli::bash::variable::declaration::get_info() {
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_STRING=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_SCALER=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_ARRAY=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_ARRAY=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_MAP=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_MAP=false

    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_NAMED=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER=false
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER=false

    local FLAGS="${1-}"

    if [[ "${FLAGS}" == *n* ]]; then
        FLAGS="${FLAGS/n/}"
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_NAMED=true
    fi

    if [[ "${FLAGS}" == *r* ]]; then
        FLAGS="${FLAGS/r/}"
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY=true
    fi

    if [[ "${FLAGS}" == *x* ]]; then
        FLAGS="${FLAGS/x/}"
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED=true
    fi

    if [[ "${FLAGS}" == *u* ]]; then
        FLAGS="${FLAGS/u/}"
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER=true
        [[ ! "${FLAGS}" == *l* ]] || cli::assert "Type cannot be both upper and lower."
    fi

    if [[ "${FLAGS}" == *l* ]]; then
        FLAGS="${FLAGS/l/}"
        REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER=true
    fi

    cli::bash::type::get_info "${FLAGS}"
    
    REPLY=${REPLY}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER=${REPLY_CLI_BASH_TYPE_IS_INTEGER}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_STRING=${REPLY_CLI_BASH_TYPE_IS_STRING}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_SCALER=${REPLY_CLI_BASH_TYPE_IS_SCALER}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_ARRAY=${REPLY_CLI_BASH_TYPE_IS_ARRAY}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_ARRAY=${REPLY_CLI_BASH_TYPE_IS_INTEGER_ARRAY}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_MAP=${REPLY_CLI_BASH_TYPE_IS_MAP}
    REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_MAP=${REPLY_CLI_BASH_TYPE_IS_INTEGER_MAP}
}

cli::bash::variable::declaration::get_info::self_test() {
    cli::assert::eval() { eval "$@" || cli::assert; }

    test() {
        local EXPECTED_TYPE="$1"
        shift

        [[ "${REPLY}" == "${EXPECTED_TYPE}" ]] \
            || cli::assert "${REPLY} != ${EXPECTED_TYPE}"

        for p in "$@"; do
            cli::assert::eval "\${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_${p}}"
        done

        local -i EXPECTED_TRUE=$#
        local -i ACTUAL_TRUE=0
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_NAMED}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_READONLY}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_EXPORTED}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_UPPER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_LOWER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER}; then ACTUAL_TRUE+=1; fi
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_STRING}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_SCALER}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_ARRAY}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_MAP}; then ACTUAL_TRUE+=1; fi 
        if ${REPLY_CLI_BASH_VARIABLE_DECLARATION_IS_INTEGER_MAP}; then ACTUAL_TRUE+=1; fi 

        (( ACTUAL_TRUE == EXPECTED_TRUE )) || cli::assert
    }

    ${CLI_COMMAND[@]} ---; test '' STRING SCALER
    ${CLI_COMMAND[@]} --- i; test i INTEGER SCALER
    ${CLI_COMMAND[@]} --- A; test A MAP
    ${CLI_COMMAND[@]} --- a; test a ARRAY
    ${CLI_COMMAND[@]} --- iA; test Ai INTEGER_MAP MAP
    ${CLI_COMMAND[@]} --- ia; test ai INTEGER_ARRAY ARRAY

    ${CLI_COMMAND[@]} --- Ai; test Ai INTEGER_MAP MAP
    ${CLI_COMMAND[@]} --- ai; test ai INTEGER_ARRAY ARRAY

    ${CLI_COMMAND[@]} --- r; test '' STRING SCALER READONLY
    ${CLI_COMMAND[@]} --- x; test '' STRING SCALER EXPORTED
    ${CLI_COMMAND[@]} --- l; test '' STRING SCALER LOWER
    ${CLI_COMMAND[@]} --- u; test '' STRING SCALER UPPER

    ${CLI_COMMAND[@]} --- rxl; test '' STRING SCALER READONLY EXPORTED LOWER
}
