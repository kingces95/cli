#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli core variable get-info"
    "cli core variable name fields"
    "cli core variable name modifications"
)

cli::core::variable::children::help() {
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

cli::core::variable::children() {
    [[ ${ARG_SCOPE} ]] || cli::assert 'Missing scope.'
    local -n SCOPE_REF=${ARG_SCOPE}

    local NAME="$1"
    [[ ${NAME} ]] || cli::assert 'Missing variable name.'

    if ! cli::core::variable::get_info "${NAME}" \
        || ${REPLY_CLI_CORE_VARIABLE_IS_BUILTIN}; then
        MAPFILE=()
        return
    fi

    if ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED}; then
        ARG_TYPE="${REPLY}" \
            cli::core::variable::name::fields ${NAME}

    elif ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED}; then
        ARG_TYPE="${REPLY}" \
            cli::core::variable::name::modifications ${NAME}
    fi
}

cli::core::variable::children::self_test() {
    local ARG_SCOPE='MY_SCOPE'

    local -A CLI_TYPE_VERSION=(
        [major]='integer'
        [minor]='integer'
    )

    local -Ar CLI_TYPE_TEST=( 
        [string]='string'
        [version]='version'
    )

    local -A MY_SCOPE=(
        [MY_TEST]='test'
        [MY_TEST_STRING]='string'
        [MY_TEST_VERSION]='version'
        [MY_TEST_VERSION_MAJOR]='integer'
        [MY_TEST_VERSION_MINOR]='integer'
        [MY_MM_STRING]='map_of map_of string'
        [MY_MM_STRING_0]='map_of string'
        [MY_MM_STRING_0_0]='string'
    )

    local MY_TEST_STRING='Hello world!'
    local MY_TEST_VERSION_MAJOR=1
    local MY_TEST_VERSION_MINOR=2
    local -A MY_MM_STRING=( ['a']=0 )
    local -A MY_MM_STRING_0=( ['b']=0 )
    local -A MY_MM_STRING_0_0='Goodbye world!'

    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} ---mapfile MY_TEST) \
        - <<< $'MY_TEST_VERSION\nMY_TEST_STRING'
    
    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} ---mapfile MY_TEST_VERSION) \
        - <<< $'MY_TEST_VERSION_MINOR\nMY_TEST_VERSION_MAJOR'

    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} ---mapfile MY_MM_STRING) - <<< MY_MM_STRING_0
    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} ---mapfile MY_MM_STRING_0) - <<< MY_MM_STRING_0_0
    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} ---mapfile MY_MM_STRING_0_0) /dev/null
}
