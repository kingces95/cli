#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable declare
cli::source cli core variable read
cli::source cli core variable write
cli::source cli core variable put
cli::source cli core variable unset

cli::args::parse::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Parse a command line.

Description
    Consume a stream of tokens produced via 'cli args tokenize' and produce a
    serialized stream of 'cli_args'. Accept as the first positional argument
    a serialized stream of 'map' of aliases. Aliases will be resolved.

Arguments
    --                      : Metadata stream.
EOF
    cat << EOF

Examples
    Parse 'grp cmd --option value -hg -- a0 a1'
        cli args tokenize -- grp cmd --option value -h --param/key value -- a0 a1 \\
        | ${CLI_COMMAND[@]} -- <( echo 'h help' )

    Produces:
        path grp
        path cmd
        property param key value
        positional a0
        positional a1
        named help 
        named option value
EOF
}

cli::args::parse::main() {
    local -A SCOPE=()
    ARG_SCOPE='SCOPE'

    ARG_TYPE='map' \
        cli::core::variable::declare ALIAS
    cli::core::variable::read ALIAS < "${1-/dev/null}"

    ARG_TYPE='cli_tokens' \
        cli::core::variable::declare TOKENS

    while read token_name identifier; do
        local token="CLI_ARG_TOKEN_${token_name}"

        TOKENS_ID+=( "${!token}" )
        TOKENS_IDENTIFIER+=( "${identifier}" )
    done

    ARG_META_ALIASES=ALIAS \
        cli::args::parse 'TOKENS'
    ARG_META_ALIASES=ALIAS \
        cli::args::parse 'TOKENS'
    local ARGS=${REPLY}

    cli::core::variable::write ${ARGS}
}

cli::args::parse() {
    : ${ARG_SCOPE?'Missing scope.'}
    local TOKENS=${1?'Missing tokens.'}
    
    local -n ALIAS_REF=${ARG_META_ALIASES}
    local -n TOKEN_REF="${TOKENS}_ID"
    local -n IDENTIFIER_REF="${TOKENS}_IDENTIFIER"
    
    local ARGS='REPLY_CLI_PARSE_ARGS'
    cli::core::variable::unset ${ARGS}
    ARG_TYPE='cli_args' \
        cli::core::variable::declare ${ARGS}

    local -i named_count=0
    local -i current=0
    local token_name=
    local identifier=
    local token=

    read_token() {
        token=${TOKEN_REF[$current]}
        token_name=${CLI_ARG_TOKEN[$token]}
        identifier=${IDENTIFIER_REF[$current]}

        # if (( $# > 0 )); then
        #     assert_token_is "$@"
        # fi
        current=$(( current + 1 ))
    }

    START() {
        read_token

        while (( token != CLI_ARG_TOKEN_EOF )); do

            if (( token == CLI_ARG_TOKEN_DASH )); then
                FLAG
            elif (( token == CLI_ARG_TOKEN_DASH_DASH )); then
                OPTION
            elif (( token == CLI_ARG_TOKEN_DASH_DASH_DASH )); then
                INTERNAL_OPTION
            elif (( token == CLI_ARG_TOKEN_END_OPTIONS )); then
                POSITIONAL
            else
                cli::fail "Unexpected arg '${identifier}' (token type ${token_name})" \
                    "encountered while parsing cli."
            fi
        done
    }

    POSITIONAL() {
        read_token

        while (( token != CLI_ARG_TOKEN_EOF )); do
            # assert_token_is TOKEN_VALUE
            cli::core::variable::put ${ARGS} positional "${identifier}"
            read_token
        done
    }

    FLAG() {

        # trap for unknown arguments
        local alias="${ALIAS_REF[$identifier]-}"
        if [[ -z "${alias}" ]]; then
            cli::fail "Unexpected unknown alias \"-${identifier}\"" \
                "passed as argument ? to command '${CLI_COMMAND[@]}'."
        fi

        identifier="${alias}"
        OPTION
    }

    INTERNAL_OPTION() {
        local option="${identifier}"
        read_token

        # list of values (typically only one but could be array or properties)
        while (( token == CLI_ARG_TOKEN_VALUE )); do
            read_token 
        done
    }

    OPTION() {
        local option="${identifier}"
        read_token

        if (( named_count == 0 )); then
            cli::core::variable::put ${ARGS} first_named "${option}"
        fi
        named_count=$(( named_count + 1 ))
        
        # flags
        if (( token != CLI_ARG_TOKEN_VALUE )); then
            cli::core::variable::put ${ARGS} named "${option}" ''
            return
        fi

        # list of values (typically only one but could be array or properties)
        while (( token == CLI_ARG_TOKEN_VALUE )); do
            cli::core::variable::put ${ARGS} named "${option}" "${identifier}"
            read_token 
        done
    }

    START

    REPLY=${ARGS}
}

cli::args::parse::self_test() {
    diff <(
        cli args tokenize -- --myarr a b c --myprops a=0 b=1 c=2 \
            | ${CLI_COMMAND[@]} --
    ) - <<-EOF
		first_named myarr
		named myprops a=0
		named myprops b=1
		named myprops c=2
		named myarr a
		named myarr b
		named myarr c
		EOF

    diff <(
        cli args tokenize -- -h --help opt --help key=value -- a0 a1 \
        | ${CLI_COMMAND[@]} -- <( echo $'h help\nt test\n' )
    ) - <<-EOF
		first_named help
		positional a0
		positional a1
		named help
		named help opt
		named help key=value
		EOF
}
