#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli args parse"
    "cli args resolve"
    "cli args tokenize"
    "cli args verify"
)

cli::args::declare::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Tokenizes, parses, resolves, and verifies a command line and then returns a map of
    bash names to types (e.g. ARG_HELP=boolean) for local declaration.

Description
    Arguments \$1-\$n is the command line.

    ARG_SCOPE is the name of the scope.
    ARG_META is the name of a variable of type cli_meta.
    ARG_ARGS is the name of a local variable of type cli_args.
    ARG_TOKENS is the name of a local variable of type cli_tokens.

    RESULT is set to the name of local variable of type cli_meta_group.
EOF
}

cli::args::initialize::main() {
    : ${ARG_SCOPE?'Missing scope.'}
    : ${ARG_META?'Missing metadata.'}

    ARG_SCOPE=${ARG_SCOPE} \
    ARG_META=${ARG_META} \
        cli::args::initialize
    local ARGS=${REPLY}

    cli::core::variable::write ${ARGS}
}

cli::args::initialize() {
    : ${ARG_SCOPE?'Missing scope.'}
    : ${ARG_META?'Missing metadata.'}

    # ARG_TYPE='cli_tokens' \
    #     cli::core::variable::declare REPLY_TOKENS
    # ARG_TYPE='cli_args' \
    #     cli::core::variable::declare REPLY_ARGS

    local TOKENS
    local ARGS
    local META_GROUP

    # tokenize
    cli::args::tokenize "$@"
    TOKENS=${REPLY}

    # parse
    ARG_ALIAS=${ARG_META}_ALIAS \
        cli::args::parse ${TOKENS}
    ARGS=${REPLY}

    # resolve
    ARG_GROUPS=${ARG_META}_GROUP \
        cli::args::resolve ${ARGS}
    META_GROUP=${REPLY}

    # verify
    ARG_META_GROUP=${META_GROUP} \
        cli::args::verify ${ARGS}

    # return group
    REPLY=${META_GROUP}
}

cli::args::declare::self_test() (
    local CLI_LOCAL='CLI_LOCAL_0'

    local -A SCOPE=()
    ARG_SCOPE='SCOPE'

    # declare metadata
    local ARG_META='MY_META'
    ARG_TYPE='cli_meta' \
        cli::core::variable::declare ${ARG_META}

    # load metadata
    cli::core::variable::read ${ARG_META} < <( 
        cli dsl sample ---load 
    )

    # cli dsl sample
    diff <( 
        ${CLI_COMMAND[@]} -- --id 42 -f banana -h --header Foo -- a0 a1 
    ) - <<-EOF || cli::assert
		first_named id
		positional a0
		positional a1
		named fruit banana
		named id 42
		named header Foo
		EOF
return

    meta() {
        echo 'type props map'
        echo 'regex props ^[0-9]$'
    }
    
    # supply list (e.g. '--props a=0 b=1')
    cli args tokenize -- --props a=0 b=1 \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named props' \
            'named props a=0' \
            'named props b=1'

    meta() {
        echo 'type name array'
        echo 'regex name ^[a-z]$'
    }

    # supply list (e.g. '--name a b')
    cli args tokenize -- --name a b \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named name' \
            'named name a' \
            'named name b'

    # supply list with regex mismatch (e.g. '--name 0')
    cli args tokenize -- --name a b 0 \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Unexpected value '0' for argument '--name' passed to command 'cli args initialize'." \
            "Expected a value that matches regex '^[a-z]$'."
                
    meta() {
        echo 'type name array'
        echo 'allow name a'
        echo 'allow name b'
    }

    # supply list with allow mismatch (e.g. '--name 0')
    cli args tokenize -- --name a b 0 \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Unexpected value '0' for argument '--name' passed to command 'cli args initialize'." \
            "Expected a value in the set { b a }."

    meta() {
        echo 'type name string'
        echo 'require name'
    }

    # fail to supply required named argument (e.g. no '--name')
    cli args tokenize \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Missing required argument '--name' in call to command '${CLI_COMMAND[@]}'."

    # empty string for required named argument (e.g. '--name ""')
    cli args tokenize -- --name \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Required argument '--name' passed to command 'cli args initialize' has empty value."

    # provide unknown named argument (e.g. '--bad')
    cli args tokenize -- --name foo --bad \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Unexpected unknown argument '--bad' passed to command '${CLI_COMMAND[@]}'."

    # provide required named argument (e.g. '--name bar')
    cli args tokenize -- --name foo \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named name' \
            'named name foo' 

    meta() {
        echo 'type value string'
        echo 'regex value ^[0-9]+$'
    }

    # fail regex (e.g. '--value 1a')
    cli args tokenize -- --value 1a \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Unexpected value '1a' for argument '--value' passed to command 'cli args initialize'." \
            "Expected a value that matches regex '^[0-9]+$'."

    # provide required named argument (e.g. '--value 42')
    cli args tokenize -- --value 42 \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named value' \
            'named value 42' 

    meta() {
        echo 'type color string'
        echo 'default color black'
    }

    #  default (e.g. '--color black')
    cli args tokenize \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named' \
            'named color black' 

    # override default value (e.g. --color white)
    cli args tokenize -- --color white \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named color' \
            'named color white'

    # override default value with alias (e.g. -c white)
    cli args tokenize -- -c white \
        | cli args parse -- <( echo 'c color' ) \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named color' \
            'named color white'

    meta() {
        echo 'type help boolean'
    }

    # default boolean
    cli args tokenize \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named'

    # implicit boolean (e.g. '--help')
    cli args tokenize -- --help \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named help' \
            'named help'

    # bad allowed value (e.g. '--help bad')
    cli args tokenize -- --help bad \
        | cli args parse \
        | assert::fails "${CLI_COMMAND[@]} -- <( meta )" \
            "Unexpected value 'bad' for argument '--help'" \
            "passed to command 'cli args initialize'." \
            "Expected a value that matches regex '^true$|^false$|^$'."

    meta() {
        echo 'positional true'
    }

    # positional argument allowed
    cli args tokenize -- -- a0 a1 \
        | cli args parse \
        | ${CLI_COMMAND[@]} -- <( meta ) \
        | assert::pipe_records_eq \
            'first_named' \
            'positional a0' \
            'positional a1'
)
