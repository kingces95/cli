#! inline

CLI_IMPORT=(
    "cli bash stack trace"
    "cli stderr dump"
)

cli::stderr::assert::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copies "ASSERT FAILED:" followed by a IFS join of the arguments or, if
    there are no aguments, than 'Condition failed' to stderr stream before 
    issuing a CTRL-C.

Examples
    Test a condition
        [[ ${foo} == 'bar' ]] || ${CLI_COMMAND[@]} -- 'Foo does not equal bar.'
EOF
}

cli::stderr::assert() {
    if (( $# == 0 )); then 
        set 'Condition failed'
    fi

    {
        echo "ASSERT FAILED:" "$*"
        cli::bash::stack::trace \
            | sed 's/^/  /'
    } | cli::stderr::dump
}

cli::stderr::assert::self_test() (
    test() {
        set -m
        cli::stderr::assert "$@" \
            2>&1 1> /dev/stderr
    }

    diff <(test 'oops!') - <<-EOF || cli::assert
		ASSERT FAILED: oops!
		  test "oops!"                                       /Users/Setup/git/cli/src/stderr/assert:40
		  self_test                                          /Users/Setup/git/cli/src/stderr/assert:44
		  cli stderr assert --self-test                      /Users/Setup/git/cli/cli:6
		EOF

    diff <(test) - <<-EOF || cli::assert
		ASSERT FAILED: Condition failed
		  test                                               /Users/Setup/git/cli/src/stderr/assert:40
		  self_test                                          /Users/Setup/git/cli/src/stderr/assert:51
		  cli stderr assert --self-test                      /Users/Setup/git/cli/cli:6
		EOF
)
