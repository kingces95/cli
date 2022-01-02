#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::temp::remove::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Unlink a temporary file, directory, or fifo from the file system and
    update internal accounting.

Description
    The positional arguments are the paths to temporary files, directories,
    or fifo pipes to be deleted unregistered for automatic cleanup in the
    exit trap. 
EOF
}

cli::temp::remove::inline() {

    local -n CLI_SUBSHELL_TEMP_FILE_BASHPID=CLI_SUBSHELL_TEMP_FILE_${BASHPID}

    # unlink files/directories
    for FILE in "$@"; do
        if ! ${CLI_SUBSHELL_TEMP_FILE_BASHPID[${FILE}]-}; then
            continue
        fi
          
        unset "CLI_SUBSHELL_TEMP_FILE_BASHPID[${FILE}]"

        if [[ ! -a "${FILE}" ]]; then
            :
        elif [[ -d "${FILE}" ]]; then
            rm -f -r "${FILE}"
            rm -f -r "${FILE}"
        else
            rm -f "${FILE}"
        fi
    done
}

cli::temp::remove::self_test() {
    cli::source cli temp file

    mapfile -t < <(
        # create temp file
        cli::temp::file::inline
        echo "${REPLY}"
        set "${REPLY}"

        # create temp file an explicitly delete it
        cli::temp::file::inline
        echo "${REPLY}"
        set "$@" "${REPLY}"
        rm "${REPLY}"

        cli::temp::remove::inline "$@"

        # explictly re-create file
        echo > "${REPLY}"
    )

    (( ${#MAPFILE[@]} == 2 )) || cli::assert
    [[ ! -a "${MAPFILE[0]}" ]] || cli::assert
    [[ -a "${MAPFILE[1]}" ]] || cli::assert

    rm "${MAPFILE[1]}"
}
