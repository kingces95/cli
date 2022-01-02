#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::set::test::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Test an associative array for a key.

Description
    Argument \$1 is the name of the associative array.
    Argument \$2 is the value of key for which to test.
EOF
}

cli::set::test() {
    local -n SET_REF=${1:?'Missing set'}
    shift 

    local KEY="$*"
    [[ "${KEY}" ]] || cli::assert 'Missing key'
    
    [[ ${SET_REF[${KEY}]+hit} == 'hit' ]]
}

cli::set::test::self_test() {
    local KEY='foo bar'
    local -A SET=( [${KEY}]=true )

    cli::set::test SET "${KEY}" || cli::assert
    ! cli::set::test SET "${KEY} baz" || cli::assert
}
