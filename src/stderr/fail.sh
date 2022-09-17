CLI_IMPORT=(
    "cli stderr dump"
)

cli::stderr::fail::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print a message then kill the process group.

Description
    Report an error to the user using stderr. The arguments are joined together with IFS.
EOF
}

cli::stderr::fail() {
    echo "$*" \
        | cli::stderr::dump
}

cli::stderr::fail::self_test() (
    cli temp file ---source
    cli stderr message ---source

    set -m

    cli::temp::file
    local FILE="${REPLY}"

    assert() {
        cli::stderr::fail $@
    }

    # assert multistage failure does not interleave
    ! ( assert a | assert b ) 2> "${FILE}" || cli::assert
    egrep -q '^(a+b+|b+a+)$' < <(cat "${FILE}" | tr -d '\n') || cli::assert

    # assert control-c kills pipeline
    ! ( assert a | { read; assert b; } ) 2> "${FILE}" || cli::assert
    egrep -q '^a+$' < "${FILE}" || cli::assert
)
