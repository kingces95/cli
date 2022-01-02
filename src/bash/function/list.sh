#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash filter glob

cli::bash::function::list::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    List functions that match a provided name.

Description
    Positional arguments \$1, \$2, etc are function names that optionally end in '*'.

    If a function does not exist, nothing is copied to stdout.
EOF
}

::cli::bash::function::list::inline() {
    declare -F \
        | awk '{ print $3 }' \
        | ::cli::bash::filter::glob::inline "$@"
}

cli::bash::function::list::self_test() (
    diff <(${CLI_COMMAND[@]} --) /dev/null
    diff <(${CLI_COMMAND[@]} -- NOT_DEFINED) /dev/null
    diff <(${CLI_COMMAND[@]} -- 'NOT_DEFINED*') /dev/null

    MY_FUNCTION() {
        :
    }

    MY_OTHER_FUNCTION() {
        :
    }

    diff <(${CLI_COMMAND[@]} -- 'MY_FUNCTION') - <<< 'MY_FUNCTION'
    diff <(${CLI_COMMAND[@]} -- 'MY_FUNC*') - <<< 'MY_FUNCTION'

    # initialized values are reported (wild card)
    diff <(${CLI_COMMAND[@]} 'MY_*') - <<-EOF
		MY_FUNCTION
		MY_OTHER_FUNCTION
		EOF
)
