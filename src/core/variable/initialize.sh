CLI_IMPORT=(
    "cli core variable get-info"
    "cli core variable name fields"
)

cli::core::variable::initialize::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Initialize a bash variable for a given type.

Description
    /$1 is the name of the variable.

    ARG_SCOPE is the active scope.
EOF
}

cli::core::variable::initialize() {
    local SCOPE_NAME="${ARG_SCOPE-}"
    [[ "${SCOPE_NAME}" ]] || cli::assert 'Missing scope.'

    local NAME="${1-}"
    [[ "${NAME}" ]] || cli::assert 'Missing name.'

    cli::core::variable::get_info ${NAME}

    local TYPE="${REPLY}"
    local -n REF="${NAME}"
    if ${REPLY_CLI_CORE_VARIABLE_IS_STRING}; then
        REF=
    elif ${REPLY_CLI_CORE_VARIABLE_IS_INTEGER}; then
        REF=0
    elif ${REPLY_CLI_CORE_VARIABLE_IS_BOOLEAN}; then
        REF=false
    elif ${REPLY_CLI_CORE_VARIABLE_IS_ARRAY}; then
        REF=()
    elif ${REPLY_CLI_CORE_VARIABLE_IS_MAP}; then
        REF=()
    elif ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED}; then
        REF=()
    else
        ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED} || cli::assert

        ARG_TYPE=${TYPE} \
            cli::core::variable::name::fields ${NAME}
        local FIELD_NAMES=( "${MAPFILE[@]}" )

        # recursively initialize fields
        local FIELD_NAME
        for FIELD_NAME in "${FIELD_NAMES[@]}"; do
            cli::core::variable::initialize "${FIELD_NAME}"
        done
    fi
}

cli::core::variable::initialize::self_test() (
    local -A SCOPE=(
        ['MY_STRING']='string'
        ['MY_BOOLEAN']='boolean'
        ['MY_INTEGER']='integer'
        ['MY_ARRAY']='array'
        ['MY_MAP']='map'
        ['MY_MAP_OF']='map_of string'
        ['MY_UDT']='udt'
    )
    local ARG_SCOPE='SCOPE'

    local MY_STRING
    ${CLI_COMMAND[@]} --- MY_STRING
    diff <(declare -p MY_STRING) - <<< 'declare -- MY_STRING=""'

    local MY_BOOLEAN
    ${CLI_COMMAND[@]} --- MY_BOOLEAN
    diff <(declare -p MY_BOOLEAN) - <<< 'declare -- MY_BOOLEAN="false"'

    local -i MY_INTEGER
    ${CLI_COMMAND[@]} --- MY_INTEGER
    diff <(declare -p MY_INTEGER) - <<< 'declare -i MY_INTEGER="0"'

    local -a MY_ARRAY
    ${CLI_COMMAND[@]} --- MY_ARRAY
    diff <(declare -p MY_ARRAY) - <<< 'declare -a MY_ARRAY=()'

    local -A MY_MAP
    ${CLI_COMMAND[@]} --- MY_MAP
    diff <(declare -p MY_MAP) - <<< 'declare -A MY_MAP=()'

    local -A MY_MAP_OF
    ${CLI_COMMAND[@]} --- MY_MAP_OF
    diff <(declare -p MY_MAP_OF) - <<< 'declare -A MY_MAP_OF=()'

    cli core variable declare ---source

    local -A CLI_TYPE_VERSION=(
        [major]='integer'
        [minor]='integer'
    )

    ARG_TYPE=version \
        cli::core::variable::declare MY_VERSION

    MY_VERSION_MAJOR=1
    MY_VERSION_MINOR=2

    ${CLI_COMMAND[@]} --- MY_VERSION

    diff <(cli::dump 'MY_VERSION_*' | sort -k3) - <<-EOF
		declare -i MY_VERSION_MAJOR="0"
		declare -i MY_VERSION_MINOR="0"
		EOF
)
