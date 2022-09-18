
cli::self_test::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Run a self test for every command. 
    
Description
    Commands are found via recursive search starting at '--dir'.
    Those commands are then invoked with the flag '--self-test'.
    If all test succeed, the exit code is 0, otherwise 1.

Arguments
    --                      : The group to search for commands.
    --dry-run -d     [Flag] : Shows what tests would be run.
EOF
}

report() {
    local command="$1"

    # interpret no output as a success
    if ! read result; then
        return
    fi

    # interpret any output as a failure
    exit_code=1
    echo "${command}"
    cat <(echo ${result}) - | sed 's/^/>   /'
}

cli::self_test::main() {
    local exit_code=0

    # search for commands starting at --dir
    cli find --type c -- "$@" | {
        while read command; do 

            if $ARG_DRY_RUN; then
                echo "${command} --self-test"
                continue
            fi

            echo "${command} --self-test"

            # problem: when a test fails it issues a ctrl-c which kills the harness
            # setsid isolates the harness, but if the test hangs then ctrl-c doesn't kill it
            # running with setsid takes down the codespace for reasons unknown!

            # execute each command's self test
            set +e
            # https://unix.stackexchange.com/a/670117/437828
            setsid --wait \
                bash -c "${command} --self-test" 2>&1 \
                | report "${command}"
            set -e
        done
    }

    exit "${exit_code}"
}
