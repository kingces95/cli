#! inline

CLI_IMPORT=(
    "cli path name"
)

cli::core::variable::load::help() {
cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Read records from a files found in a direcotry and write the records to stdout 
    using the file name as the first field followed by the fields of the record.

Description
    DIR is the directory to scan for files.
    ARG_VARIABLE is the variable to set.
    ARG_SCOPE is a map containing variables types.
EOF
}

cli::core::variable::load() {
    local DIR="$1"
    [[ -d "${DIR}" ]] || cli::assert "Directory '$DIR' not found."

    set "${DIR}/*"

    for FILE in $@; do
        cli::path::name "${FILE}"
        local FILE_NAME="${REPLY}"
    
        [[ "${FILE_NAME}" =~ ${CLI_REGEX_VARIABLE_NAME} ]] \
            || cli::assert "${FILE_NAME} !=~ ${CLI_REGEX_VARIABLE_NAME}"
    
        while IFS= read -r; do
            echo "${FILE_NAME}" "${REPLY}"
        done < "${FILE}"
    done
}

cli::core::variable::load::self_test() (
    cli temp dir ---source
    cli core variable save ---source

    cli::temp::dir
    local DIR="${REPLY}"

    cli::core::variable::save "${DIR}" <<-EOF
			foo r00 r01 r02
			foo r10 r11 r12
			bar s00 s01 s\ 02
			baz z00
			EOF

    diff <( ${CLI_COMMAND[@]} "${DIR}" | sort ) \
        - <<-EOF
			bar s00 s01 s\ 02
			baz z00
			foo r00 r01 r02
			foo r10 r11 r12
			EOF
)
