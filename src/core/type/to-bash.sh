#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::core::type::to_bash::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return bash type given a core type.

Description
    Argument \$1 - \$n represent a type.

    REPLY contains the name of bash type.
EOF
}

cli::core::type::to_bash() {
    local TYPE="${1-}"

    case "${TYPE}" in
        'string') REPLY= ;;
        'integer') REPLY=i ;;
        'array') REPLY=a ;;
        'map') REPLY=A ;;
        'map_of') REPLY=A ;;
        'boolean') REPLY= ;;
        *) return 1 ;;
    esac
}

cli::core::type::to_bash::self_test() {
    diff <( ${CLI_COMMAND[@]} ---reply string ) - <<< ''
    diff <( ${CLI_COMMAND[@]} ---reply integer ) - <<< 'i'
    diff <( ${CLI_COMMAND[@]} ---reply boolean ) - <<< ''
    diff <( ${CLI_COMMAND[@]} ---reply array ) - <<< 'a'
    diff <( ${CLI_COMMAND[@]} ---reply map_of array ) - <<< 'A'
    diff <( ${CLI_COMMAND[@]} ---reply map ) - <<< 'A'
    ! ${CLI_COMMAND[@]} --- udt || cli::assert
}
