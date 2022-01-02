#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::subshell::on_exit::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Registister a function to be called when the subshell exits.

Description
    Positional arguments are the names of functions to be called when the
    subshell exits. Functions are called in the order they were registered.
EOF
}

cli::subshell::on_exit::inline() {
    local -ga "CLI_SUBSHELL_ON_EXIT_${BASHPID}+=()"
    local -n CLI_SUBSHELL_ON_EXIT=CLI_SUBSHELL_ON_EXIT_${BASHPID}

    if (( ${#CLI_SUBSHELL_ON_EXIT[@]} == 0 )); then
        cli::subshell::on_exit::trap() {
            local -n CLI_SUBSHELL_ON_EXIT=CLI_SUBSHELL_ON_EXIT_${BASHPID}
            for delegate in ${CLI_SUBSHELL_ON_EXIT[@]}; do
                ${delegate}
            done
        }
        trap cli::subshell::on_exit::trap EXIT
    fi

    CLI_SUBSHELL_ON_EXIT+=( "$@" )
}

cli::subshell::on_exit::self_test() {
    handler_a() { echo "a"; }
    handler_b() { echo "b"; }

    inline() { cli::subshell::on_exit::inline "$@"; }

    # multipule handlers
    diff <( inline handler_a handler_b ) <(printf '%s\n' a b) \
        || cli::assert

    # multipule calls
    diff <( inline handler_a; inline handler_b ) <(printf '%s\n' a b) \
        || cli::assert

    # subshell isolation
    diff <( (inline handler_a); inline handler_b ) <(printf '%s\n' a b) \
        || cli::assert
}