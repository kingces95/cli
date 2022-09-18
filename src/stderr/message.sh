#! inline

CLI_IMPORT=(
    "cli stderr cat"
    "cli process signal"
)

cli::stderr::buffer::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Print 1024 lines of a character repeated 1024 times.

Description
    Interleaving stderr output occurs when multipule stages of a pipeline fail
    and each stage emits a long message (e.g. a stack trace). This function
    emulates a pseudo stacktrace for testing purposes. 
EOF
}

cli::stderr::message() {
    local CHAR="$1"
    shift

    local THOUSAND=1024

    local INDEX
    local THOUSAND_CHARS=$(
        for ((INDEX=0; INDEX<${THOUSAND}; INDEX++)); do 
            printf "${CHAR}"
        done
    )

    for ((INDEX=0; INDEX<${THOUSAND}; INDEX++)); do {
        echo ${THOUSAND_CHARS}
    } done
}

cli::stderr::message::self_test() (
    local LINE=$(cli stderr message -- a | head -n 1)

    [[ "${#LINE}" == 1024 ]] || cli::assert
    [[ $(cli::stderr::message a | wc -l) == 1024 ]] || cli::assert
)
