#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli stderr lock"
    "cli temp file"
)

cli::stderr::cat::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copy stdin to stderr.

Description
    Copy stdin to a temporary log file, take a lock, copy the file to stderr. 
EOF
}

cli::stderr::cat() {

    # create a temporary file
    cli::temp::file
    local SCRATCH="${REPLY}"

    # write to file instead of stderr so generator can take lock
    cat > "${SCRATCH}"

    # lock and copy file to stderr
    cat "${SCRATCH}" \
        | cli::stderr::lock >&2 

    # cleanup
    rm "${SCRATCH}"
}

cli::stderr::cat::self_test() {
    cli temp file ---source
    cli stderr message ---source

    cli::temp::file
    local FILE="${REPLY}"

    log() {
        cli::stderr::message $@ | cli::stderr::cat
    }

    # assert multistage failure does not interleave
    ( log a | log b ) 2> "${FILE}" || cli::assert
    egrep -q '^(a+b+|b+a+)$' < <(cat "${FILE}" | tr -d '\n') || cli::assert
}
