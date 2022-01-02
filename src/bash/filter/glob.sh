#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::filter::glob::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Echo each argument to stdout.

Description
    Argument \$1 - \$n are the arguments to copy to stdout.
EOF
}

cli::bash::filter::glob::inline() {
    while read -r; do
        local FILTER
        for FILTER in "$@"; do
            if [[ "${REPLY}" == ${FILTER} ]]; then
                echo "${REPLY}"
                break;
            fi
        done
    done
}

cli::bash::filter::glob::self_test() {
    diff <(${CLI_COMMAND[@]} -- <<< $'a\nbc\nd') /dev/null || cli::assert
    diff <(${CLI_COMMAND[@]} -- a 'b*' <<< $'a\nbc\nd') - <<< $'a\nbc' || cli::assert
}
