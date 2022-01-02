#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::stderr::lock::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Blocks until taking an exclusive lock on path then copies the stdin to stdout.

Description
    First positional argument is a path to the file to use as lock.
EOF
}

::cli::stderr::lock::inline() {
    flock -x "${CLI_LOADER_LOCK}" cat
}

cli::stderr::lock::self_test() {
    lock() {
        ::cli::stderr::lock::inline
    }

    for (( i=0; i<64; i++ )); do
        local result=$({
            { 
                printf A
                sleep 0
                printf A
            } | lock >&2 | {
                printf B
                sleep 0
                printf B
            } | lock >&2
        } 2>&1 ) 
        
        [[ ${result} =~ AABB|BBAA ]] \
            || assert::fail "Result ${result} interleaves A and B."
    done  
}
