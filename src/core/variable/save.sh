CLI_IMPORT=(
    "cli bash write"
)

cli::core::variable::save::help() {
cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Save a stream of records to files using the first field as the file name
    and the remaining fields as the file content.

Description
    Save a stream of records read from stdin to files in a directory. The
    first field of each record is the file in which the remaing fields
    will be written.

    Existing files will be overwritten.

    The directory will be created if it does not already exist.
EOF
}

cli::core::variable::save() {
    local DIR="$1"

    if [[ -d "${DIR}" ]]; then
        rm -Rf "${DIR}"
    fi

    mkdir -p "${DIR}"

    while read -a REPLY; do

        # load record into locals
        set "${REPLY[@]}"

        # shift file name
        local NAME="$1"
        [[ "${NAME}" =~ ${CLI_REGEX_VARIABLE_NAME} ]] \
            || cli::assert "${NAME} !=~ ${CLI_REGEX_VARIABLE_NAME}"
        shift

        # construct file path
        local FILE_PATH="${DIR}/${NAME}"

        # write record
        cli::bash::write "$@" >> "${FILE_PATH}"
    done
}

cli::core::variable::save::self_test() (   
    cli temp dir ---source
    
    cli::temp::dir
    local DIR="${REPLY}"

    ${CLI_COMMAND[@]} -- "${DIR}" <<-EOF
		foo r00 r01 r02
		foo r10 r11 r12
		bar s00 s01 s\ 02
		EOF

    diff "${DIR}/foo" <(
        echo 'r00 r01 r02'
        echo 'r10 r11 r12'
    )

    diff "${DIR}/bar" <(
        echo 's00 s01 s\ 02'
    )
)
