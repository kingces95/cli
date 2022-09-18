#! inline

cli::bash::variable::list::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    List variables that are initialized and match a provided name.

Description
    Positional arguments \$1, \$2, etc are variable names that optionally end in '*'.

    All variables which match any of the positional arguments are copied to stdout.

    If a variable does not exist, nothing is printed.

Arguments
    --                      : The variables names to emit.
EOF
}

cli::bash::variable::list() {

    local NAME
    for NAME in "$@"; do

        if [[ ! "${NAME}" ]]; then
            continue

        elif [[ "${NAME}" =~ ^.*[*]$ ]]; then

            local MATCH
            for MATCH in $(eval "echo \${!${NAME}}"); do
                # do not recurse! test -v arr=() is false
                echo "${MATCH}"
            done

        elif [[ -v "${NAME}" ]]; then
            echo "${NAME}"

        else
            # declare -a arr=()
            local MATCH
            for MATCH in $(eval "echo \${!${NAME}*}"); do
                if [[ "${MATCH}" == "${NAME}" ]]; then
                    echo "${NAME}"
                fi
            done
        fi
    done | sort
}

cli::bash::variable::list::self_test() (
    diff <(${CLI_COMMAND[@]} --) /dev/null
    diff <(${CLI_COMMAND[@]} -- MY_NOT_DEFINED) /dev/null
    diff <(${CLI_COMMAND[@]} -- 'MY_NOT_DEFINED*') /dev/null

    # declared
    local MY_DECL_STRING
    local -a MY_DECL_ARRAY
    local -A MY_DECL_MAP
    local -i MY_DECL_NUMBER

    # declared and initialized
    local MY_EMPTY_STRING=""
    local -a MY_EMPTY_ARRAY=()
    local -A MY_EMPTY_MAP=()

    # declared, initialized, and set
    local MY_STRING='Hello world!'
    local -a MY_ARRAY=(a)
    local -A MY_MAP=([a]=0)
    local -i MY_NUMBER=42

    # basic reporting
    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'MY_STRING'
    diff <(${CLI_COMMAND[@]} -- 'MY_STR*') - <<< 'MY_STRING'

    # declared only variables are not reported
    diff <(${CLI_COMMAND[@]} -- \
        MY_DECL_ARRAY \
        MY_DECL_MAP \
        MY_DECL_STRING \
        MY_DECL_NUMBER) /dev/null

    # initialized values are reported (wild card)
    diff <(${CLI_COMMAND[@]} 'MY_*') - <<-EOF
		MY_ARRAY
		MY_EMPTY_ARRAY
		MY_EMPTY_MAP
		MY_EMPTY_STRING
		MY_MAP
		MY_NUMBER
		MY_STRING
		EOF

    # initialized values are reported (explicit)
    diff <(${CLI_COMMAND[@]} \
        MY_ARRAY \
        MY_EMPTY_ARRAY \
        MY_EMPTY_MAP \
        MY_EMPTY_STRING \
        MY_MAP \
        MY_NUMBER \
        MY_STRING) - <<-EOF
		MY_ARRAY
		MY_EMPTY_ARRAY
		MY_EMPTY_MAP
		MY_EMPTY_STRING
		MY_MAP
		MY_NUMBER
		MY_STRING
		EOF
)
