#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli stderr lock
cli::source cli temp file

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

::cli::stderr::cat::inline() {

    # create a temporary file
    ::cli::temp::file::inline

    # write to file instead of stderr so generator can take lock
    cat > "${REPLY}"

    # lock and copy file to stderr
    cat "${REPLY}" \
        | ::cli::stderr::lock::inline >&2 

    # cleanup
    rm "${REPLY}"
}

cli::stderr::cat::self_test() {
    local CHAR_COUNT=1024

    # a pipeline stage that emits a log larger than the pipe buffer
    segment() {

        local CHARS=$(
            for ((i=0; i<${CHAR_COUNT}; i++)); do 
                printf $1
            done
        )

        for ((i=0; i<${CHAR_COUNT}; i++)); do {
            printf ${CHARS}
        } done \
            | ::cli::stderr::cat::inline
    }

    local DUMPS=$( 
        # simulate a mulit stage pipeline log 
        ( segment 'a' | segment 'b' ) 2>&1 || cli::assert 
    )

    # assert the logs from the two pipeline stages do not inerleave
    [[ "${DUMPS}" =~ ^(a+b+|b+a+)$ ]] || cli::assert
}
