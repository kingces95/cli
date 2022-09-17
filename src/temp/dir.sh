CLI_IMPORT=(
    "cli temp file"
)

cli::temp::dir::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Create a temporary directory, set REPLY to its path, and register a trap to
    recursively delete the directory upon subshell exit.

Description
    The first argument is the name of the variable to return the path to the
    temporary directory. The default is REPLY. The directory name does _not_
    end in a slash.

    Upon exit a trap will recusively delete the temporary directory.
EOF
}

cli::temp::dir() {
    cli::temp::file "$@"
    rm -f "${REPLY}"
    mkdir "${REPLY}"
}

cli::temp::dir::self_test() (

    mapfile -t < <(
        # create a temp dir
        cli::temp::dir
        [[ -d "${REPLY}" ]] || cli::assert
        echo "${REPLY}"

        # create a temp dir to explicitly delete
        cli::temp::dir
        [[ -d "${REPLY}" ]] || cli::assert
        rm -r "${REPLY}"

        # create a temp dir returned via a custom name
        cli::temp::dir
        local MY_REPLY="${REPLY}"
        [[ -d "${MY_REPLY}" ]] || cli::assert
        echo "${MY_REPLY}"

        # test recursive directory delete
        echo > "${MY_REPLY}/file.log"
    )

    (( ${#MAPFILE[@]} == 2 )) || cli::assert
    [[ ! -a "${MAPFILE[0]}" ]] || cli::assert
    [[ ! -a "${MAPFILE[1]}" ]] || cli::assert

    [[ "${MAPFILE}" =~ [^/]$ ]] || cli::assert
)
