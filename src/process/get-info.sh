#!/usr/bin/env CLI_TOOL=cli bash-cli-part

cli::process::get_info::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get the type of a bash variable.

Description
    Arguments \$1 is the process id. Default is the current process.

    Set information:

        REPLY_CLI_PROCESS_ID
        REPLY_CLI_PROCESS_GROUP_ID
EOF
}

cli::process::get_info() {
    local PID="${1-${BASHPID}}"

    REPLY_CLI_PROCESS_ID=
    REPLY_CLI_PROCESS_PARENT_ID=
    REPLY_CLI_PROCESS_GROUP_ID=
    REPLY_CLI_PROCESS_TERMINAL_ID=
    REPLY_CLI_PROCESS_USER_ID=
    REPLY_CLI_PROCESS_UTILIZATION=
    REPLY_CLI_PROCESS_COMMAND=
    REPLY_CLI_PROCESS_ARGS=

    read REPLY_CLI_PROCESS_ID \
        REPLY_CLI_PROCESS_PARENT_ID \
        REPLY_CLI_PROCESS_GROUP_ID \
        REPLY_CLI_PROCESS_TERMINAL_ID \
        REPLY_CLI_PROCESS_USER_ID \
        REPLY_CLI_PROCESS_UTILIZATION \
        REPLY_CLI_PROCESS_COMMAND \
        REPLY_CLI_PROCESS_ARGS \
        < <(ps -p "${PID}" -o pid=,ppid=,pgid=,tname=,euid=,pcpu=,ucmd=,args=)
}

cli::process::get_info::self_test() {
    cli::process::get_info

    [[ ${REPLY_CLI_PROCESS_ID} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_PARENT_ID} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_GROUP_ID} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_TERMINAL_ID} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_USER_ID} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_UTILIZATION} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_COMMAND} ]] || cli::assert
    [[ ${REPLY_CLI_PROCESS_ARGS} ]] || cli::assert

    group() { cli::process::get_info; echo "${REPLY_CLI_PROCESS_GROUP_ID}"; }

    local PID="${REPLY_CLI_PROCESS_ID}"
    (
        cli::process::get_info
        [[ "${REPLY_CLI_PROCESS_PARENT_ID}" == "${PID}" ]] || cli::assert
    )

    local GPID="${REPLY_CLI_PROCESS_GROUP_ID}"
    (
        # enable job control; new subprocs and their subprocs get their own GPID
        ( [[ $(group) == ${GPID} ]] || cli::assert )
        set -m
        ( [[ ! $(group) == ${GPID} ]] || cli::assert )
    )
}
