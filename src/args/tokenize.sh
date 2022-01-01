#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable declare
cli::source cli core variable unset

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Tokenizes command line arguments.

Description
    Tokenizes command line arguments. Theoretically, a command line could be 
    matched by a regular expression. This command effectively does that match
    and emits 
    
        an array of paths
        an associative array of named arguments (aka options), and 
        an array of positional arguments (aka arguments)

    For example, 
    
        ${CLI_COMMAND[@]} -- bin sequence --name even -v -- two four six 
        
    produces:

        path bin
        path sequence
        option name even
        option v true
        argument two
        argument four
        argument six

    The command line syntax is based off the Azure az tool with the additon that:
    
        1. multipule single character options can be included behind the 
           same single dash with the last option optionally having a value.
        2. arguments following '--' are positional arguments. 
        
    For example, 

       '-gh v' 
        
    produces: 
    
        option g true
        option h v

    Options proceeded by a double dash must be composed of lowercase letters, numbers, 
    or dash, and must start with a letter. 
    
    Options behind a single dash must be a lowercase letter.

    If an internal flag (e.g. '---which') appears before the first option, then
    parsing ends with success.

Arguments
    --                      : Command line arguments.
EOF
    cat << EOF

Examples
    Tokenize 'bin cli --k0 v0 --flag -xyz v1 -- a0 a1'.
        ${CLI_COMMAND[@]} -- bin cli --k0 v0 --flag -xyz v1 -- a0 a1
EOF
}

cli::args::tokenize::main() {   
    local -A SCOPE=()
    ARG_SCOPE='SCOPE'

    local TOKENS='REPLY_CLI_ARGS_TOKENS'

    ::cli::args::tokenize::inline "$@"
    ::cli::args::tokenize::inline "$@"
    local -n TOKENS_ID=${TOKENS}_ID
    local -n TOKENS_IDENTIFIER=${TOKENS}_IDENTIFIER

    for i in "${!TOKENS_ID[@]}"; do
        echo ${CLI_ARG_TOKEN[TOKENS_ID[$i]]} "${TOKENS_IDENTIFIER[$i]-}"
    done
}

::cli::args::tokenize::inline() {
    : ${ARG_SCOPE?'Missing scope.'}

    local TOKENS='REPLY_CLI_ARGS_TOKENS'
    ::cli::core::variable::unset::inline ${TOKENS}
    ARG_TYPE='cli_tokens' \
        ::cli::core::variable::declare::inline ${TOKENS}

    local -n TOKEN_REF="${TOKENS}_ID"
    local -n IDENTIFIER_REF="${TOKENS}_IDENTIFIER"

    local NAME_REGEX='[a-z][a-z0-9-]*'

    local DASH_REGEX="^-[^-].*$" # enable better error messages
    local DASH_FLAGS_REGEX="^-([a-z]+)$"

    local DASH_DASH_REGEX="^--[^-].*$" # enable better error messages
    local DASH_DASH_OPTION_REGEX="^--(${NAME_REGEX})$"

    local DASH_DASH_DASH_REGEX="^---[^-].*$" # enable better error messages
    local DASH_DASH_DASH_OPTION_REGEX="^---(${NAME_REGEX})$"

    local DASH_DASH='--'

    yield() {
        TOKEN_REF+=( $1 )
        IDENTIFIER_REF+=( "${2-}" )
    }
    
    while (( $# > 0 )); do        
        if [[ "$1" == ${DASH_DASH} ]]; then
            yield ${CLI_ARG_TOKEN_END_OPTIONS}
            shift

            while (( $# > 0 )); do
                yield ${CLI_ARG_TOKEN_VALUE} "$1"
                shift
            done

            break
        
        elif [[ "$1" == ---* ]]; then

            if [[ ! "$1" =~ ^---([a-z][a-z0-9-]*)$ ]]; then
                cli::fail "Unexpected option \"$1\"" \
                    "does not match regex ${DASH_DASH_DASH_OPTION_REGEX}" \
                    "passed to command \"${CLI_COMMAND[@]}\"."
            fi

            yield ${CLI_ARG_TOKEN_DASH_DASH_DASH} "${1:3}"

        elif [[ "$1" == --* ]]; then
                
            if [[ ! "$1" =~ ^--([a-z][a-z0-9-]*)$ ]]; then
                cli::fail "Unexpected option \"$1\"" \
                    "does not match regex ${DASH_DASH_OPTION_REGEX}" \
                    "passed to command \"${CLI_COMMAND[@]}\"."
            fi

            yield ${CLI_ARG_TOKEN_DASH_DASH} "${1:2}"

        elif [[ "$1" == -* ]]; then

            if [[ ! "$1" =~ ^-([a-z][a-z0-9-]*)$ ]]; then
                cli::fail "Unexpected option \"$1\"" \
                    "does not match regex ${DASH_FLAGS_REGEX}" \
                    "passed to command \"${CLI_COMMAND[@]}\"."
            fi

            yield ${CLI_ARG_TOKEN_DASH} "${1:1}"

        else
            yield ${CLI_ARG_TOKEN_VALUE} "$1"
        fi

        shift
    done

    yield ${CLI_ARG_TOKEN_EOF}

    REPLY=${TOKENS}
}

cli::args::tokenize::self_test() {

    diff <(${CLI_COMMAND[@]} --) - <<< 'EOF '

    diff <(${CLI_COMMAND[@]} -- --k v -- a0) - <<-EOFF
		DASH_DASH k
		VALUE v
		END_OPTIONS 
		VALUE a0
		EOF 
		EOFF

    diff <(${CLI_COMMAND[@]} -- --k 'v v' -- 'a a') - <<-EOFF
		DASH_DASH k
		VALUE v v
		END_OPTIONS 
		VALUE a a
		EOF 
		EOFF

return

    # escape
    diff <(${CLI_COMMAND[@]} -- --k 'v v' -- 'a a') - <<-EOFF
		DASH_DASH k
		VALUE v v
		END_OPTIONS 
		VALUE a a
		EOF 
		EOFF

    # named argument default aliasing (e.g. '-k' -> '--k' )
    diff <(${CLI_COMMAND[@]} -- -k v) - <<-EOFF
		DASH k
		VALUE v
		EOF 
		EOFF

    # named argument packed (e.g. '-mn' -> '--m --n' )
    diff <(${CLI_COMMAND[@]} -- -mn) - <<-EOFF
		DASH mn
		EOF 
		EOFF

    # named argument implicit value (e.g. '' )
    diff <(${CLI_COMMAND[@]} -- --m -n) - <<-EOFF
		DASH_DASH m
		DASH n
		EOF 
		EOFF

    # positional
    diff <(${CLI_COMMAND[@]} -- -- a0 a1) - <<-EOFF
		END_OPTIONS 
		VALUE a0
		VALUE a1
		EOF 
		EOFF

return
    assert::fails "${CLI_COMMAND[@]} -- -!" \
        "Unexpected option \"-!\" does not match regex ^-([a-z]+)$" \
        "passed to command \"cli args tokenize\"."

    assert::fails "${CLI_COMMAND[@]} -- --!" \
        "Unexpected option \"--!\" does not match regex ^--([a-z][a-z0-9-]*)$" \
        "passed to command \"cli args tokenize\"."

    assert::fails "${CLI_COMMAND[@]} -- ---!" \
        "Unexpected option \"---!\" does not match regex ^---([a-z][a-z0-9-]*)$" \
        "passed to command \"cli args tokenize\"."
}
