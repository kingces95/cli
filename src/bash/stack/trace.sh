#! inline

CLI_IMPORT=(
    "cli bash stack call"
    "cli bash stack process"
)

cli::bash::stack::trace::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print the bash stack followed by the process stack.
EOF
}

cli::bash::stack::trace() {
    cli::bash::stack::call
    if [[ -n "${CLI_STACK_SHOW_PROCESS-}" ]]; then
        cli::bash::stack::process
    fi
}

cli::bash::stack::trace::self_test() {

    # cli::stderr::fail 'Test failure!'

    my_trap() {
        echo ---
        echo "${BASH_COMMAND} -> ${1-0}"
        cli::bash::stack::trace 1 | sed 's/^/  /'
    }

    # trap 'my_trap $?' ERR

    subpipe() {
        local pid=$BASHPID
        printf '%s %s:%s %s\n' "$1" "$pid" "${BASH_SUBSHELL}" $$ > /dev/stderr
        printf '%s\n' "$1" "$(lsof -a -p "$pid" -d 0,1,2)" > /dev/stderr
        cat
        echo hello | grep bar
    }

    pipe() {
        cat | subpipe "${1}${1}" | cat
    }

    echo hi | pipe a
}
