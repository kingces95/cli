#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::cache::test::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Test if a file exists and is older than another file.

Description
    Argument \$1 is the path to the generated file.

    Argument \$2 - \$n are the source files which the generated file depends.
    
    Success if the generated file exists and is older than the source 
    file, otherwise failure.
EOF
}

cli::cache::test() {
    local CACHE="$1"
    shift

    # if the cache does not exist than fail
    if [[ ! -f "${CACHE}" ]]; then 
        return 1
    fi

    while (( $# > 0 )); do
        local SOURCE="$1"
        shift

        # if the source is not older than the cache, then the cache is outdated
        if [[ ! "${SOURCE}" -ot "${CACHE}" ]]; then
            return 1
        fi
    done
}

cli::cache::test::self_test() {
    cli::temp::file 
    local OLDEST="${REPLY}"

    cli::temp::file 
    local OLD="${REPLY}"
    
    cli::temp::file
    local NEW="${REPLY}"

    ! ${CLI_COMMAND[@]} -- 'no_cache_file' "${OLD}" || cli::assert
    ! ${CLI_COMMAND[@]} -- "${OLD}" "${OLD}" || cli::assert
    ! ${CLI_COMMAND[@]} -- "${OLD}" "${NEW}" || cli::assert
    ! ${CLI_COMMAND[@]} -- "${OLD}" "${OLDEST}" "${NEW}" || cli::assert
    ${CLI_COMMAND[@]} -- "${NEW}" "${OLD}" || cli::assert
    ${CLI_COMMAND[@]} -- "${NEW}" "${OLD}" "${OLD}" || cli::assert
}
