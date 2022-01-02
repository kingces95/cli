#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash literal
cli::source cli attribute is-defined

cli::bash::stack::call::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print the callstack.

Description
    Print the callstack where each record is composed of:

        frame file line
EOF
}

# see https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
cli::bash::stack::call::inline() {
    
    # argument counts by frame
    set -- ${BASH_ARGV[@]}

    # bash stack
    local -i argc=0
    for (( i=0; i<${#FUNCNAME[@]}; i++ )); do
        local -a args=()
        local inline_args=''
        local funcname="${FUNCNAME[$i]}"

        if (( i == ${#FUNCNAME[@]}-1 )); then funcname='bash::main'; fi

        # reverse argv for i-th frame
        for (( j=${BASH_ARGC[$i]}-1; j>=0; j-- )); do
            args+=( "$(cli::bash::literal::inline "${BASH_ARGV[${j}+${argc}]}")" )
        done

        # pop argc stack for i-th frame
        argc+=${BASH_ARGC[$i]}

        if [[ ! "${CLI_STACK_SHOW_HIDDEN-}" ]] \
            && cli::attribute::is_defined::inline \
            'METHOD' "${funcname}" 'cli_bash_stack_hidden_attribute'; then
            continue
        fi

        # inline args when they won't disturb formatting
        inline_args="${args[@]}"
        if (( ${#inline_args} > 80 )); then
            inline_args=
        else
            args=()
        fi

        printf '%-50s %s:%s\n' \
            "${funcname} ${inline_args}" "${BASH_SOURCE[$i]}" ${BASH_LINENO[$i-1]-}

        for arg in "${args[@]}"; do
            echo "${arg}"
        done | sed 's/^/  /'
    done
}

cli::bash::stack::call::self_test() {
    trigger() { return 1; }

    my_trap() {
        echo
        cli::bash::stack::call::inline 1
    }

    trap 'my_trap' ERR

    subpipe() {
        local pid=$BASHPID
        printf '%s %s:%s %s\n' "$1" "$pid" "$BASH_SUBSHELL" $$ > /dev/stderr
        printf '%s\n' "$1" "$(lsof -a -p "$pid" -d 0,1,2)" > /dev/stderr
        cat
        echo hello | trigger
    }

    pipe() {
        cat | subpipe "${1}${1}" | cat
    }

    echo hi | pipe a
}
