#! inline

CLI_IMPORT=(
    "cli bash emit function"
    "cli core emit scope"
    "cli core emit variable"
    "cli core variable find"
)

cli::core::emit::global::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Emit a global variable.

Description
    ARG_SCOPE is the name of the scope variable.

    \$1 is the variable name.
EOF
}

cli::core::emit::global() {
    : "${ARG_SCOPE?'Missing scope.'}"

    local NAME=${1-}
    [[ "${NAME}" ]] || cli::assert 'Missing variable name.'

    cli::core::variable::find ${NAME} \
        | while read; do cli::core::emit::variable ${REPLY} g; done

    echo

    cli::core::variable::find ${NAME} \
        | cli::core::emit::scope
}

cli::core::emit::global::self_test() {
    local ARG_SCOPE='MY_SCOPE'

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

    diff <(${CLI_COMMAND[@]} -- MY_TEST) - <<-EOF
		declare -ga MY_TEST_ARRAY_FIELD=(
		    "x"
		    "y"
		    "z"
		)
		declare -g MY_TEST_BOOLEAN_FIELD="true"
		declare -gi MY_TEST_INTEGER_FIELD="21"
		declare -gA MY_TEST_MAP_FIELD=(
		    [z]="26"
		)
		declare -g MY_TEST_STRING_FIELD="Hi world!"
		
		CLI_SCOPE+=(
		    [MY_TEST]="test"
		    [MY_TEST_ARRAY_FIELD]="array"
		    [MY_TEST_BOOLEAN_FIELD]="boolean"
		    [MY_TEST_INTEGER_FIELD]="integer"
		    [MY_TEST_MAP_FIELD]="map"
		    [MY_TEST_STRING_FIELD]="string"
		)
		EOF
}
