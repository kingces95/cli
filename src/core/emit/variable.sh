#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable get-info
cli::source cli core variable get
cli::source cli bash emit variable

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Variable a declaration and initialization.

Description
    ARG_SCOPE is the scope name.

    \$1 is the variable name.
    \$2 optional are modifier flags (e.g. 'r' for read-only).
EOF
}

::cli::core::emit::variable::inline() {
    : "${ARG_SCOPE?'Missing scope.'}"

    local NAME=$1
    [[ "${NAME}" ]] || cli::assert 'Missing name.'

    local FLAGS=${2-}

    ::cli::core::variable::get_info::inline "${NAME}" \
        || cli::assert "Variable '${NAME}' not in scope."
    local TYPE=( "${MAPFILE[@]}" )

    # user defined types have no backing bash variable
    if ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED}; then
        return
    fi

    ::cli::bash::emit::variable::inline ${NAME} ${FLAGS}
}

cli::core::emit::variable::self_test() {
    local ARG_SCOPE='MY_SCOPE'
    
    local -A MY_SCOPE=(
        [MY_STRING]='string'
        [MY_BOOLEAN]='boolean'
        [MY_INTEGER]='integer'
        [MY_ARRAY]='array'
        [MY_MAP]='map'
    )

    local MY_STRING='Hello world!'
    local MY_BOOLEAN='true'
    local -i MY_INTEGER=42
    local -a MY_ARRAY=( a b c )
    local -A MY_MAP=( [a]=0 )

    local -A MY_SCOPE+=(
        [MY_MODIFIED]='map_of string'
        [MY_MODIFIED_0]='string'
    )

    local -A MY_MODIFIED=( [Hello]=0 )
    local MY_MODIFIED_0='World!'

    local -Ar CLI_TYPE_TEST=( 
        [STRING_FIELD]='string'
        [BOOLEAN_FIELD]='boolean'
        [INTEGER_FIELD]='integer'
        [ARRAY_FIELD]='array'
        [MAP_FIELD]='map'
    )

    local -A MY_SCOPE+=(
        [MY_TEST]='test'
        [MY_TEST_STRING_FIELD]='string'
        [MY_TEST_BOOLEAN_FIELD]='boolean'
        [MY_TEST_INTEGER_FIELD]='integer'
        [MY_TEST_ARRAY_FIELD]='array'
        [MY_TEST_MAP_FIELD]='map'
    )
    local MY_TEST_STRING_FIELD='Hi world!' 
    local MY_TEST_BOOLEAN_FIELD=true 
    local -i MY_TEST_INTEGER_FIELD=21 
    local -a MY_TEST_ARRAY_FIELD=( x y z )
    local -A MY_TEST_MAP_FIELD=( [z]=26 )

    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'declare -- MY_STRING="Hello world!"'
    diff <(${CLI_COMMAND[@]} -- MY_BOOLEAN) - <<< 'declare -- MY_BOOLEAN="true"'
    diff <(${CLI_COMMAND[@]} -- MY_INTEGER) - <<< 'declare -i MY_INTEGER="42"'
    diff <(${CLI_COMMAND[@]} -- MY_ARRAY) - <<-EOF
		declare -a MY_ARRAY=(
		    [0]="a"
		    [1]="b"
		    [2]="c"
		)
		EOF
    diff <(${CLI_COMMAND[@]} -- MY_MAP) - <<-EOF
		declare -A MY_MAP=(
		    [a]="0"
		)
		EOF
    diff <(${CLI_COMMAND[@]} -- MY_MODIFIED) - <<-EOF
		declare -A MY_MODIFIED=(
		    [Hello]="0"
		)
		EOF
    diff <(${CLI_COMMAND[@]} -- MY_MODIFIED_0) - <<< 'declare -- MY_MODIFIED_0="World!"'
    diff <(${CLI_COMMAND[@]} -- MY_TEST) /dev/null
}
