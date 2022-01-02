#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core type get-info

cli::core::type::unmodify::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return the unmodified type of a type.

Description
    Arguments \$1 - \$n are elemens of a type.

    Return a type less one modifiers. For example, the unmodified type of
    
        map_of map_of string

    is 

        map_of string

    Fails if type is not modified.
EOF
}

cli::core::type::unmodify() {
    MAPFILE=()

    # type must actually be modified
    cli::core::type::get_info "$@"
    if ! $REPLY_CLI_CORE_TYPE_IS_MODIFIED; then
        MAPFILE=( "$@" )
        return 1
    fi

    # word split the type
    set $@

    # shift the modifier
    shift

    MAPFILE=( "$@" )
}

cli::core::type::unmodify::self_test() {
    ! ${CLI_COMMAND[@]} -- 'boolean' || cli::assert
    diff <( ${CLI_COMMAND[@]} ---mapfile map_of boolean ) - <<< 'boolean' || cli::assert
    diff <( ${CLI_COMMAND[@]} ---mapfile map_of map_of boolean ) - <<< $'map_of\nboolean' || cli::assert
}
