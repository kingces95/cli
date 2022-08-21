#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::process::tree::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Load the parent process of each process into map REPLY_CLI_PROCESS_TREE.

Description
    Key of REPLY_CLI_PROCESS_TREE is the process and the value it's parent.
EOF
}

cli::process::tree() {
    declare -Ag REPLY_CLI_PROCESS_TREE=()

    local PROCESS_ID
    local PARENT_PROCESS_ID

    while read PROCESS_ID PARENT_PROCESS_ID; do
        REPLY_CLI_PROCESS_TREE["${PROCESS_ID}"]="${PARENT_PROCESS_ID}"
    done < <(ps -o pid=,ppid=)
}

cli::process::tree::self_test() {
    cli::process::tree
    [[ "${REPLY_CLI_PROCESS_TREE[$$]-}" ]] || cli::assert

    ( 
        cli::process::tree
        [[ "${REPLY_CLI_PROCESS_TREE[$BASHPID]-}" == "$$" ]] || cli::assert
    )
}
