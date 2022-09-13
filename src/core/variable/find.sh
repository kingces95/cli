#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli core variable match"
)

cli::core::variable::find::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Match ane echo variable names and their children.

Description
    ARG_SCOPE is the name of the scope variable.
    
    Arguments \$1-\$n are variable names.

    Copy matching variable names to stdout. 
EOF
}

cli::core::variable::find() {
    : "${ARG_SCOPE?'Missing scope.'}"

    local -a NAMES=( "$@" )
    mapfile -t < <( printf '%s_*\n' "${NAMES[@]}" )

    cli::core::variable::match "${NAMES[@]}" "${MAPFILE[@]}"
}

cli::core::variable::find::self_test() {
    local ARG_SCOPE='MY_SCOPE'

    local -A MY_SCOPE=(
        [MY_FOO]='test'
        [MY_MAP_OF]='map_of string'
        [MY_MAP_OF_0]='my string'
        [MY_TEST]='test'
        [MY_TEST_STRING]='string'
        [MY_TEST_BOOLEAN]='boolean'
        [MY_TEST_INTEGER]='integer'
        [MY_TEST_ARRAY]='array'
        [MY_TEST_MAP]='map'
    )

    diff <(ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} -- "MY_TEST" "MY_MAP_OF") <(
        echo MY_MAP_OF
        echo MY_MAP_OF_0
        echo MY_TEST
        echo MY_TEST_ARRAY
        echo MY_TEST_BOOLEAN
        echo MY_TEST_INTEGER
        echo MY_TEST_MAP
        echo MY_TEST_STRING     
    )
}
