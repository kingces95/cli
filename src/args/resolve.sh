CLI_IMPORT=(
    "cli args check"
    "cli core variable declare"
    "cli core variable put"
    "cli core variable read"
    "cli core variable resolve"
    "cli core variable write"
    "cli set intersect"
)

cli::args::reslove::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return the command group implied by switches found in the arguments.

Description
    Argument \$1 is variable of type 'cli_meta'.

    Stdin contains a stream of type 'cli_args'.

    ARG_SCOPE is the working scope.

    RESULT is a variable of type 'cli_meta_group'.

EOF
    cat << EOF

Examples
    cli args tokenize -- --header foo --help \\
        | cli args parse \\
        | cli args check -- \\
            <( cli sample kitchen-sink ---load )
EOF
}

cli::args::resolve::main() {
    ARG_TYPE='cli_args' \
        cli::core::variable::declare MY_ARGS
    cli::core::variable::read MY_ARGS

    ARG_META_GROUPS=${ARG_META}_GROUP \
        cli::args::resolve MY_ARGS
}

cli::args::resolve() {
    [[ ${ARG_SCOPE:-} ]] || cli::assert 'Missing scope.'
    [[ ${ARG_META_GROUPS:-} ]] || cli::assert 'Missing metadata.'

    local ARGS=${1-}
    [[ ${ARGS} ]] || cli::assert 'Missing args.'

    local -n GROUP_REF=${ARG_META_GROUPS}

    local GROUP_ID='*'
    if (( ${#GROUP_REF[@]} > 1 )); then
        cli::set::intersect ${ARG_META_GROUPS} ${ARGS}_NAMED
        
        (( ${#REPLY_MAP[@]} == 1 )) \
            || cli::assert \
                "Expected a single named argument from the set { ${!GROUP_REF[@]} }" \
                "be declared to discriminate the command group." \
                "Instead '${REPLY_MAP[@]}' discrimiator(s) were declared."

        GROUP_ID="${!REPLY_MAP[@]}" 
    fi

    cli::core::variable::resolve ${ARG_META_GROUPS} "${GROUP_ID}"
}

cli::args::resolve::self_test() (

    # cli sample kitchen-sink
    (
        local -A SCOPE=()
        ARG_SCOPE='SCOPE'

        # declare metadata
        local ARG_META='MY_META'
        ARG_TYPE='cli_meta' \
            cli::core::variable::declare ${ARG_META}

        # load metadata
        cli::core::variable::read ${ARG_META} < <( 
            cli sample kitchen-sink ---load 
        )

        diff <(
            # sample command line
            local COMMAND_LINE='--id 42 -f banana -h --header Foo -- a0 a1'
            cli args tokenize -- ${COMMAND_LINE} \
                | cli args parse -- \
                    <( cli::core::variable::write ${ARG_META}_ALIAS ) \
                | ${CLI_COMMAND[@]} ---reply
        ) - <<< 'MY_META_GROUP_0'

        diff <(
            # sample command line
            local COMMAND_LINE='--name foo -f banana -h --header Foo -- a0 a1'
            cli args tokenize -- ${COMMAND_LINE} \
                | cli args parse -- \
                    <( cli::core::variable::write ${ARG_META}_ALIAS ) \
                | ${CLI_COMMAND[@]} ---reply
        ) - <<< 'MY_META_GROUP_1'
    )

    # cli sample simple
    (
        local -A SCOPE=()
        ARG_SCOPE='SCOPE'

        # declare metadata
        local ARG_META='MY_META'
        ARG_TYPE='cli_meta' \
            cli::core::variable::declare ${ARG_META}

        # load metadata
        cli::core::variable::read ${ARG_META} < <( 
            cli sample simple ---load 
        )

        diff <(
            # sample command line
            local COMMAND_LINE='-f banana -h --header Foo -- a0 a1'
            cli args tokenize -- ${COMMAND_LINE} \
                | cli args parse -- \
                    <( cli::core::variable::write ${ARG_META}_ALIAS ) \
                | ${CLI_COMMAND[@]} ---reply
        ) - <<< 'MY_META_GROUP_0'
    )
)
