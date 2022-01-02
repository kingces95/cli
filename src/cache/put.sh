#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli path dir
cli::source cli temp file

cli::cache::put::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Copy stdin to a temp file and then move the file to a cache path.

Description
    Argument $1 is the path to replace with the content read from stdin.
EOF
}

cli::cache::put::inline() {
    local CACHE="$1"

    cli::path::dir::inline "${CACHE}"
    local DIR="${REPLY}"
    mkdir -p "${DIR}"

    cli::temp::file::inline
    local TEMP="${REPLY}"
    cat > "${TEMP}"

    mv "${TEMP}" "${CACHE}"

    REPLY="${CACHE}"
}

cli::cache::put::self_test() {
    cli::temp::file
    local CACHE="${REPLY}"
    rm "${CACHE}"

    local DIR="$(dirname "${CACHE}")"

    echo 'content' \
        | ${CLI_COMMAND[@]} -- "${CACHE}"

    [[ -f "${CACHE}" ]] || cli::assert
    diff "${CACHE}" - <<< 'content' || cli::assert
}
