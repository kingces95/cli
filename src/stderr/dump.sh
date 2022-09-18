#! inline

CLI_IMPORT=(
    "cli stderr cat"
    "cli process signal"
)

cli::stderr::dump::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Aquire exclusive stderr lock, copy stdin to stderr, and exit.

Description
    Stdin is copied to a temporary log file then the lock is taken and the file is
    copied to stderr. If the lock were taken and then stdin were copied to stdout a
    deadlock would happen if the generator of stdin aquired the lock. Copying the
    content to the temp file prevents that deadlock.  
EOF
}

cli::stderr::dump() {

    # copy stdin to stderr
    cli::stderr::cat

    # this would interleave
    # cat >&2

    # issue control-c
    cli::process::signal
}

cli::stderr::dump::self_test() (
    cli temp file ---source
    cli stderr message ---source

    set -m

    cli::temp::file
    local SCRATCH="${REPLY}"

    assert() {
        cli::stderr::message $@ | cli::stderr::dump
    }

    # assert multistage failure does not interleave
    ! ( assert a | assert b ) 2> "${SCRATCH}" \
        || cli::assert 'Expected pipeline to report control-c error.'
    egrep -q '^(a+b+|b+a+)$' < <(cat "${SCRATCH}" | tr -d '\n') \
        || cli::assert 'Interleave detected.'

    # assert control-c kills pipeline
    ! ( assert a | { read; assert b; } ) 2> "${SCRATCH}" \
        || cli::assert 'Control-c failed to kill pipeline.'
    egrep -q '^a+$' < "${SCRATCH}" \
        || cli::assert 'Expected error from first stage of pipeline.'
)
