#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Test if an attribute of a given type is declared on a target.

Description
    Argument $1 is the target type (e.g. 'METHOD')
    Argument $2 is the name of the target (e.g. 'acme::my_function')
    Argument $3 is the type of the attribute (e.g. 'cli_bash_stack_hidden_attribute')
EOF
}

::cli::attribute::is_defined::inline() {
    local target_type=${1-}; shift
    local target=${1-}; shift
    local type=${1-}; shift

    # expand assertion as more target types are needed
    [[ ${target_type} == 'METHOD' ]] || cli::assert

    # target identifies a method (or type, or command, or what-have-you)
    [[ ${target} != 'METHOD' ]] || \
        [[ ${target} =~ ${CLI_REGEX_BASH_NAME} ]] || cli::assert

    local -n targets="CLI_META_ATTRIBUTES_${target_type}"
    local index=${targets[${target}]:-}
    local -n ref="CLI_META_ATTRIBUTES_${target_type}_${index}_TYPE"

    # search the types of attributes decorating the target for a match
    for attribute in "${ref[@]}"; do
        if [[ "${attribute}" == "${type}" ]]; then
            return 0
        fi
    done

    return 1
}

cli::attribute::is_defined::self_test() {
    CLI_META_ATTRIBUTES_METHOD['acme::my_function']=0

    ${CLI_COMMAND[@]} -- \
        'METHOD' \
        'acme::my_function' \
        'cli_bash_stack_hidden_attribute' \
        || cli::assert

    ! ${CLI_COMMAND[@]} -- \
        'METHOD' \
        'acme::my_other_function' \
        'cli_bash_stack_hidden_attribute' \
        || cli::assert
}
