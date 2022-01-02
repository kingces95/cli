#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::stack::process::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print the process stack from BASHPID id to CLI_PID.
EOF
}

cli::bash::stack::process() {
    local ARG_START_PID=${1-$$}
    local ARG_END_PID=${2-${CLI_PID-}}

    # load process poset and associated command lines
    local -a pid_parent=()
    local -a pid_cmd=()
    while read pid ppid cmd; do
        pid_parent[${pid}]=${ppid}
        pid_cmd[${pid}]="${cmd}"
    done < <(ps -o pid=,ppid=,args=)

    # subprocess stack
    local pid=${BASHPID}
    local -a subshell=( ${BASHPID} )
    while (( $pid != $$ )); do
        echo "(${pid}) subshell"
        pid=${pid_parent[${pid}]}
    done

    # process stack
    local pid=${ARG_START_PID}
    for (( i=0; ${pid} > 0; i++ )); do

        echo -n "(${pid}) "
        local inline_args=${pid_cmd[${pid}]}
        if (( ${#inline_args} < 80 )); then
            echo "${inline_args}"
        else
            echo "${inline_args}" \
                | sed -e $'s/--/\\\n  --/g'
        fi

        if (( ${pid} == ${ARG_END_PID-0} )); then break; fi
        pid=${pid_parent[${pid}]-0}
    done
}

cli::bash::stack::process::self_test() {

    trap cli::bash::stack::process ERR

    subpipe() {
        local pid=$BASHPID
        printf '%s %s:%s %s\n' "$1" "$pid" "$BASH_SUBSHELL" $$ > /dev/stderr
        printf '%s\n' "$1" "$(lsof -a -p "$pid" -d 0,1,2)" > /dev/stderr
        cat
        echo hello | grep bar
    }

    pipe() {
        cat | subpipe "${1}${1}" | cat
    }

    echo hi | pipe a | pipe b
}
