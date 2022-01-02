#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core type get
cli::source cli core type get-info
cli::source cli core variable name resolve

cli::core::variable::name::fields::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Resolve the field names of user defined type given a variable name.

Description
    ARG_TYPE is the type of the variable.

    Arguments \$1 is the name of the variable.

    Return the variable names of the fields in MAPFILE. 
EOF
}

::cli::core::variable::name::fields::inline() {
    [[ ${ARG_TYPE} ]] || cli::assert 'Missing type.'

    local NAME="${1-}"
    [[ ${NAME} ]] || cli::assert 'Missing name.'

    ::cli::core::type::get_info::inline ${ARG_TYPE}

    ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED} \
        || cli::assert "Type '${ARG_TYPE}' is not user defined."

    ::cli::core::type::get::inline ${ARG_TYPE}
    local -n TYPE_REF=${REPLY}

    local RESULT=()
    local FIELD
    for FIELD in "${!TYPE_REF[@]}"; do
        ARG_TYPE=${ARG_TYPE} \
            ::cli::core::variable::name::resolve::inline "${NAME}" "${FIELD}"
        RESULT+=( "${REPLY}" )
    done

    MAPFILE=( "${RESULT[@]}" )
}

cli::core::variable::name::fields::self_test() {
    local -A CLI_TYPE_VERSION=(
        [major]='integer'
        [minor]='integer'
    )

    local -Ar CLI_TYPE_TEST=( 
        [my_string_field]='string'
        [my_boolean_field]='boolean'
        [my_integer_field]='integer'
        [my_array_field]='array'
        [my_map_field]='map'
        [my_version_field]='udt'
    )

    diff <(ARG_TYPE=test ${CLI_COMMAND[@]} ---mapfile MY_TEST | sort) <(
        echo MY_TEST_MY_ARRAY_FIELD
        echo MY_TEST_MY_BOOLEAN_FIELD
        echo MY_TEST_MY_INTEGER_FIELD      
        echo MY_TEST_MY_MAP_FIELD
        echo MY_TEST_MY_STRING_FIELD
        echo MY_TEST_MY_VERSION_FIELD
    )
}
