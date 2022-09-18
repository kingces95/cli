#! inline

CLI_IMPORT=(
    "cli bash variable get-info"
    "cli core type get"
    "cli core type get-info"
    "cli core type to-bash"
    "cli core variable get-info"
    "cli core variable initialize"
    "cli core variable name resolve"
    "cli core variable unset"
    "cli set test"
)

cli::core::variable::declare::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Declare and initialize a bash variable or variables for a given type.

Description
    Declares and initializes a global bash variable or variables depending on 
    the provided type.

    Redefinition of a variable as the same type is a no-op.
EOF
}

cli::core::variable::declare::main() {
    cli core variable parse ---source

    cli::core::variable::parse "$@"

    ARG_TYPE="${MAPFILE[@]}" \
        cli::core::variable::declare "${REPLY}"
}

cli::core::variable::declare() {
    local SCOPE_NAME="${ARG_SCOPE-}"
    [[ "${SCOPE_NAME}" ]] || cli::assert 'Missing scope.'

    local TYPE="${ARG_TYPE-}"
    [[ "${TYPE}" ]] || cli::assert 'Missing type.'

    local NAME="${1-}"
    [[ "${NAME}" ]] || cli::assert 'Missing name.'

    # redefinition is a noop
    if cli::core::variable::get_info "${NAME}"; then
        local EXISTING_TYPE="${MAPFILE[*]}"
        [[ "${EXISTING_TYPE}" == "${TYPE}" ]] || \
            cli::assert "Variable '${NAME}' of type '${EXISTING_TYPE}'" \
                "cannot be redclared type '${TYPE}'."
        return
    fi
    
    # assert bash variable does not already exist
    ! cli::bash::variable::get_info "${NAME}" \
        || cli::assert "Failed to declare '${NAME}'." \
            "Variable '${NAME}' already declared in bash as:" \
            "$( declare -p "${NAME}" )"

    # assoicate variable with its type
    local -n SCOPE_REF="${SCOPE_NAME}"
    SCOPE_REF["${NAME}"]="${TYPE}"

    cli::core::type::get_info ${TYPE} # split

    # base case
    if ! ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED}; then
        cli::core::type::to_bash ${TYPE}
        declare -g${REPLY} ${NAME}
        cli::core::variable::initialize "${NAME}"

    # user defined
    else
        local USER_DEFINED_TYPE=${REPLY}

        # bgen optimization
        # local bgen=${CLI_BGEN_DECLARE[CLI_TYPE_${TYPE^^}]-}
        # if [[ -n ${bgen} ]]; then
        #     ${bgen} ${NAME}
        #     return
        # fi
        # echo "--- MISSING BGEN FOR CLI_TYPE_${TYPE^^} ---" > /dev/stderr

        cli::core::type::get ${USER_DEFINED_TYPE}
        local -n TYPE_REF=${REPLY}

        # layout fields
        local FIELD_NAME
        for FIELD_NAME in "${!TYPE_REF[@]}"; do

            # resolve bash variable for field
            ARG_TYPE="${USER_DEFINED_TYPE}" \
                cli::core::variable::name::resolve "${NAME}" "${FIELD_NAME}"
            local FIELD_TYPE="${MAPFILE[*]}"

            # recursively initialize bash variable for field
            ARG_TYPE="${FIELD_TYPE}" \
                cli::core::variable::declare "${REPLY}"
        done
    fi
}

cli::core::variable::declare::self_test() (
    cli core type to-bash ---source

    local -A SCOPE=()
    local ARG_SCOPE='SCOPE'

    test() {
        # declare the variable
        ${CLI_COMMAND[@]} --- "$@"

        test::verify() {
            local TYPE="$1"
            local NAME="$2"

            # the variable is registered in the scope
            [[ "${SCOPE["${NAME}"]+set}" && \
                "${SCOPE["${NAME}"]}" == "${TYPE}" ]] || \
                cli::assert "${SCOPE["${NAME}"]+missing} != ${TYPE}"

            cli::core::type::get_info ${TYPE}

            if ! ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED}; then

                # get info about the underlying bash variable
                cli::bash::variable::get_info "${NAME}"
                local ACUTAL_BASH_TYPE="${REPLY}"

                # the bash variable should be initialized and mutable
                ! ${REPLY_CLI_BASH_VARIABLE_IS_UNINITIALIZED} || cli::assert
                ! ${REPLY_CLI_BASH_VARIABLE_IS_READONLY} || cli::assert

                # the bash variable type should correspond to the core type
                cli::core::type::to_bash ${TYPE} 
                local EXPECTED_BASH_TYPE="${REPLY}"

                [[ "${ACUTAL_BASH_TYPE}" == "${EXPECTED_BASH_TYPE}" ]] \
                    || cli::assert "${ACUTAL_BASH_TYPE} != ${EXPECTED_BASH_TYPE}"

                return
            fi

            # no bash variable is declared for a UDT
            ! cli::bash::variable::get_info "${NAME}" || cli::assert

            cli::core::type::get "${TYPE}"
            local -n TYPE_REF="${REPLY}"

            local FIELD
            for FIELD in "${!TYPE_REF[@]}"; do
                
                ARG_TYPE="${TYPE}" \
                    cli::core::variable::name::resolve "${NAME}" "${FIELD}"

                # recurse
                test::verify "${MAPFILE[*]}" "${REPLY}"
            done
        }

        # parse the declaration
        cli::core::variable::parse "$@"
        test::verify "${MAPFILE[*]}" "${REPLY}"
    }

    test string MY_STRING
    test integer MY_INTEGER
    test array MY_ARRAY
    test map MY_MAP
    test boolean MY_BOOLEAN
    test map_of string MY_MODIFIED

    local -A CLI_TYPE_VERSION=(
        [major]='integer'
        [minor]='integer'
    )
    test version MY_VERSION

    # kitchen sink
    local -A CLI_TYPE_UDT=(
        [my_string]='string'
        [my_integer]='integer'
        [my_boolean]='boolean'
        [my_map]='map'
        [my_array]='array'
        [my_map_of_string]='map_of string'
        [my_version]='version'
        [my_map_of_version]='map_of version'
    )
    test udt MY_UDT

    diff <(cli::dump 'MY_*' | sort -k3) - <<-EOF
		declare -a MY_ARRAY=()
		declare -- MY_BOOLEAN="false"
		declare -i MY_INTEGER="0"
		declare -A MY_MAP=()
		declare -A MY_MODIFIED=()
		declare -- MY_STRING=""
		declare -a MY_UDT_MY_ARRAY=()
		declare -- MY_UDT_MY_BOOLEAN="false"
		declare -i MY_UDT_MY_INTEGER="0"
		declare -A MY_UDT_MY_MAP=()
		declare -A MY_UDT_MY_MAP_OF_STRING=()
		declare -A MY_UDT_MY_MAP_OF_VERSION=()
		declare -- MY_UDT_MY_STRING=""
		declare -i MY_UDT_MY_VERSION_MAJOR="0"
		declare -i MY_UDT_MY_VERSION_MINOR="0"
		declare -i MY_VERSION_MAJOR="0"
		declare -i MY_VERSION_MINOR="0"
		EOF

    MY_STRING=foo
    test string MY_STRING
    [[ "${MY_STRING}" == 'foo' ]] || cli::assert "'${MY_STRING}'"
)
