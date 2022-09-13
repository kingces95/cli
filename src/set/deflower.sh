#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli set test"
)

cli::set::deflower::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Add an element to a set. Return non-zero if the element was already present.

Description
    Argument \$1 is the name of the set (associative array).
    Argument \$2 is the value of element.
EOF
}

cli::set::deflower() {
    local -n SET_REF=${1?'Missing set'}
    local KEY=${2?'Missing element value'}

    if cli::set::test "$@"; then
        return 1
    fi

    SET_REF[${KEY}]=true
}

cli::set::deflower::self_test() {
    local -A SET=()
    local KEY=(foo bar)

    cli::set::deflower SET "${KEY[*]}" || cli::assert
    cli::set::test SET "${KEY[*]}" || cli::assert
    ! cli::set::deflower SET "${KEY[*]}" || cli::assert

    diff <(declare -p SET) - <<< 'declare -A SET=(["foo bar"]="true" )' \
        || cli::assert
}
