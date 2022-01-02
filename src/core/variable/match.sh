#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash filter glob
cli::source cli bash map keys

cli::core::variable::match::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Echo variable names matching a glob.

Description
    ARG_SCOPE is the name of the scope variable.

    Arguments \$1-\$n are variable names which can be globs.

    Copy matching variable names to stdout. 
EOF
}

cli::core::variable::match() {
    : "${ARG_SCOPE?'Missing scope.'}"

    cli::bash::map::keys ${ARG_SCOPE} \
        | cli::bash::filter::glob "$@"
}

cli::core::variable::match::self_test() {
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
        echo MY_TEST
    )
}
