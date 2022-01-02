#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core type get-info
cli::source cli core variable name resolve

cli::core::variable::name::modifications::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Resolve the modified names of modified type given a variable name.

Description
    ARG_TYPE is the type of the variable.

    Arguments \$1 is the name of the modified variable.

    Return the variable names of the fields in MAPFILE. 
EOF
}

::cli::core::variable::name::modifications::inline() {
    [[ ${ARG_TYPE} ]] || cli::assert 'Missing type.'

    local NAME="${1-}"
    [[ ${NAME} ]] || cli::assert 'Missing name.'

    ::cli::core::type::get_info::inline ${ARG_TYPE}

    ${REPLY_CLI_CORE_TYPE_IS_MODIFIED} \
        || cli::assert "Type '${ARG_TYPE}' is not modified."

    local -n MAP_OF=${NAME}

    local RESULT=()
    local ORDINAL
    for ORDINAL in "${!MAP_OF[@]}"; do
        ::cli::core::variable::name::resolve::inline "${NAME}" "${ORDINAL}"
        RESULT+=( "${REPLY}" )
    done

    MAPFILE=( "${RESULT[@]}" )
}

cli::core::variable::name::modifications::self_test() {
    local -A MY_TEST=( ['foo']=0 ['bar']=1 )
    
    diff <(ARG_TYPE='map_of string' ${CLI_COMMAND[@]} ---mapfile MY_TEST | sort) <(
        echo MY_TEST_0
        echo MY_TEST_1
    )
}
