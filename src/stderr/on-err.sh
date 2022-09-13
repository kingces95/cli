#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli bash stack trace"
    "cli stderr dump"
)

cli::stderr::on_err::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Dump a stacktrace after an error trap fires.
EOF
}

cli::stderr::on_err() {
    local -a CLI_PIPESTATUS=( "${PIPESTATUS[@]}" )
    local CLI_TRAP_EXIT_CODE=${1-'?'}
    local BPID="${BASHPID}"

    # only dump if we are exiting after the trap; e.g. errexit is set (set -e)
    #   -e  Exit immediately if a command exits with a non-zero status.
    if [[ ! $- =~ e ]]; then
        return
    fi

    {
        echo -n "TRAP ERR: exit=${CLI_TRAP_EXIT_CODE}"
        if (( ${#CLI_PIPESTATUS[@]} > 1 )); then
            echo -n ", pipe=[$(cli::bash::join ',' "${CLI_PIPESTATUS[@]}")]"
        fi
        echo ", bpid=${BPID}, pid=$$"
        echo "BASH_COMMAND ERR: ${BASH_COMMAND}"

        cli::bash::stack::trace | sed 's/^/  /'
    } | cli::stderr::dump
}

cli::stderr::on_err::self_test() {
    :
}
