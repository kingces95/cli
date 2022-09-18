#! inline

CLI_IMPORT=(
    "cli subshell on-exit"
    "cli temp remove"
)

cli::temp::file::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Create a temporary file, set REPLY to its path, and register a trap to
    unlink the file upon subshell exit.

Description
    The first argument is the name of the variable to return the path to the
    temporary file. The default is REPLY.

    Upon exit a trap will run to delete the temporary file.
EOF
}

cli::temp::file() {
    # create and return a temporary file
    local TEMP_FILE=$(mktemp "${1-"${TMPDIR:-/tmp/}"}cli-XXXXXXXX")

    # record the temporary file 
    declare -gA "CLI_SUBSHELL_TEMP_FILE_${BASHPID}+=()"
    local -n CLI_SUBSHELL_TEMP_FILE_BASHPID=CLI_SUBSHELL_TEMP_FILE_${BASHPID}

    # cleanup
    if (( ${#CLI_SUBSHELL_TEMP_FILE_BASHPID[@]} == 0 )); then
        cli::temp::file::on_exit() {

            # unlink files/directories
            local -n CLI_SUBSHELL_TEMP_FILE_BASHPID=CLI_SUBSHELL_TEMP_FILE_${BASHPID}
            cli::temp::remove "${!CLI_SUBSHELL_TEMP_FILE_BASHPID[@]}"
        }

        cli::subshell::on_exit \
            cli::temp::file::on_exit
    fi

    CLI_SUBSHELL_TEMP_FILE_BASHPID+=( ["${TEMP_FILE}"]='true' )
    REPLY="${TEMP_FILE}"
}

cli::temp::file::self_test() {

    mapfile -t < <(
        # create a temp file
        cli::temp::file
        [[ -f "${REPLY}" ]] || cli::assert
        echo "${REPLY}"

        # create a temp file returned via a custom name
        cli::temp::file
        local MY_REPLY="${REPLY}"
        [[ -f "${MY_REPLY}" ]] || cli::assert
        echo "${MY_REPLY}"

        # create a temp file to explicitly delete
        cli::temp::file
        [[ -f "${REPLY}" ]] || cli::assert
        rm "${REPLY}"
    )

    (( ${#MAPFILE[@]} == 2 )) || cli::assert
    [[ ! -a "${MAPFILE[0]}" ]] || cli::assert
    [[ ! -a "${MAPFILE[1]}" ]] || cli::assert
}
