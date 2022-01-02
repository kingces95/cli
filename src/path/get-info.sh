#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::path::get_info::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Get information about a path.

Description
    Return the following predicates given a path:

    REPLY_CLI_PATH_EXISTS
    REPLY_CLI_PATH_IS_FILE
    REPLY_CLI_PATH_IS_DIRECTORY
    REPLY_CLI_PATH_IS_EXECUTABLE
    REPLY_CLI_PATH_IS_WRITABLE
    REPLY_CLI_PATH_IS_SYMBOLIC_LINK

EOF
}

cli::path::get_info::inline() {
    REPLY_CLI_PATH_EXISTS=false
    REPLY_CLI_PATH_IS_FILE=false
    REPLY_CLI_PATH_IS_DIRECTORY=false
    REPLY_CLI_PATH_IS_EXECUTABLE=false
    REPLY_CLI_PATH_IS_WRITABLE=false
    REPLY_CLI_PATH_IS_SYMBOLIC_LINK=false

    if [[ ! "${1-}" || ! -e "${1}" ]]; then
        return
    fi

    REPLY_CLI_PATH_EXISTS=true

    if [[ -f "${1}" ]]; then
        REPLY_CLI_PATH_IS_FILE=true

    elif [[ -d "${1}" ]]; then
        REPLY_CLI_PATH_IS_DIRECTORY=true

    elif [[ -L "${1}" ]]; then
        REPLY_CLI_PATH_IS_SYMBOLIC_LINK=true
    fi

    if [[ -w "${1}" ]]; then
        REPLY_CLI_PATH_IS_WRITABLE=true
    fi

    if [[ -x "${1}" ]]; then
        REPLY_CLI_PATH_IS_EXECUTABLE=true
    fi
}

cli::path::get_info::self_test() {
    cli::temp::file
    local FILE="${REPLY}"

    ${CLI_COMMAND[@]} -- "${FILE}"
    ${REPLY_CLI_PATH_EXISTS} || cli::assert
    ${REPLY_CLI_PATH_IS_FILE} || cli::assert
    ${REPLY_CLI_PATH_IS_WRITABLE} || cli::assert
    ! ${REPLY_CLI_PATH_IS_DIRECTORY} || cli::assert
    ! ${REPLY_CLI_PATH_IS_EXECUTABLE} || cli::assert
    ! ${REPLY_CLI_PATH_IS_SYMBOLIC_LINK} || cli::assert
}
