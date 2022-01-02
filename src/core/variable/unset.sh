#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable children

cli::core::variable::unset::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Match variable names and copy to stdout.

Description
    ARG_SCOPE is the name of the scope variable.

    Arguments \$1-\$n are variable names which can be globs.

    Copy matching variable names to stdout. 
EOF
}

cli::core::variable::unset() {
    [[ ${ARG_SCOPE} ]] || cli::assert 'Missing scope.'
    local -n SCOPE_REF=${ARG_SCOPE}

    while (( $# > 0 )); do
        local NAME="$1"
        shift

        cli::core::variable::children ${NAME}
        cli::core::variable::unset "${MAPFILE[@]}"

        unset "SCOPE_REF[${NAME}]"
        unset ${NAME}
    done
}

cli::core::variable::unset::self_test() {
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

    ARG_SCOPE=MY_SCOPE ${CLI_COMMAND[@]} --- MY_MM_STRING MY_TEST
    diff <(cli::dump 'MY_TEST_*' 'MY_MM_*') /dev/null
    (( ${#MY_SCOPE[@]} == 0 )) || cli::assert "${!MY_SCOPE[@]}"
}
