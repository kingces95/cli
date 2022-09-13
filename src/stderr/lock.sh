#!/usr/bin/env CLI_TOOL=cli bash-cli-part

cli::stderr::lock::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Atomic copy of stdin to stdout.

Description
    First positional argument is the path to the lock file.
EOF
}

cli::stderr::lock() {
    flock -x "${CLI_LOADER_LOCK}" cat
}

cli::stderr::lock::self_test() {
    lock() {
        cli::stderr::lock
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
