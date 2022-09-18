
cli::dsl::tokenize::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
    Read command help from stdin and emit tokens to stdout one per 
    line in the form:

        token_name line word [identifier]

    Tokenize is the first step in harvesting metadata from a command's 
    help. Metadata harvested includes names and alises of arguments,
    whether arguments are required, have an optional default value, 
    and/or a list of optional acceptable values.

    The tokenizer has a preprocessor that exlcudes processing of
    help sections that do not include the word "Arguments". 
    
    Within "Arguments" help sections the preporcessor excludes 
    argument copy is defined as text after a colon up to 
    "Required:", "Allowed values:", or a new command name. 

    Within "Arguments" help sections: CLI_DSL_TOKEN_NAME is returned for
    an argument which is a word preceeded by an indentation and 
    a double dash. CLI_DSL_TOKEN_ALIAS is returned for words which are
    preceeded by a dash. CLI_DSL_TOKEN_DEFAULT and CLI_DSL_TOKEN_ALLOWED_VALUES are
    returned for "Default:" and "Allowed values:" respectively.
    CLI_DSL_TOKEN_VALUE_COMMA and CLI_DSL_TOKEN_VALUE_PEROID are returned for words
    followed by a comma or period respectively (e.g. a default 
    value and/or allowed value lists). CLI_DSL_TOKEN_EOF is emitted last 
    except if CLI_DSL_TOKEN_ERROR is emitted, in which case it's last.
EOF
    cat << EOF

Examples
    Parse this help.
        cli dsl help tokenize -h | cli dsl help tokenize

    Parse the sample help.
        cli dsl help sample -h | cli dsl help tokenize
EOF
}

cli::dsl::tokenize::main() { 
    [[ -v CLI_DSL_LITERAL_COLON ]] || cli::assert

    local line
    local word=
    local last_word=
    local word_number=0
    local line_number=0

    # preprocessor; e.g. like #IF 0 ... #ENDIF where we are only lexing
    # when we are in an argument header and not in argument copy
    local in_argument_header=false
    local in_argument_copy=false
    yield() {
        if $in_argument_header && ! $in_argument_copy; then
            echo ${CLI_DSL_TOKEN[$1]} ${line_number} ${word_number} "${2-}"
        fi
    }

    # processor; read a line, break it up, emit tokens
    while IFS= read line; do
        line_number=$(( line_number + 1 ))
        word_number=0

        # is the line a header?
        if [[ "${line}" =~ ^[a-zA-Z] ]]; then
            word_number=1

            # does the header section declare arguments?
            local regex='Arguments([ ]when[ ](.*))?$'
            if [[ "${line}" =~ ${regex} ]]; then
                in_argument_header=true
                in_argument_copy=false

                # parameter groups
                local word="${BASH_REMATCH[2]}"
                if [[ "${word}" == ${CLI_DSL_ARG_NAME_GLOB} ]]; then
                    yield ${CLI_DSL_TOKEN_ARGUMENTS} "${word#--}"
                else
                    yield ${CLI_DSL_TOKEN_ARGUMENTS}
                fi
            else
                in_argument_header=false
            fi
            continue
        fi

        # split the line on spaces
        shopt -u nullglob # else [Required] expands to ''
        words=( ${line} )
        shopt -s nullglob

        while (( word_number < ${#words[@]} )); do
            last_word=${word}
            word=${words[${word_number}]}
            word_number=$(( word_number + 1 ))

            # e.g. ": this is argument copy."
            if [[ "$word" == "${CLI_DSL_LITERAL_COLON}" ]]; then
                in_argument_copy=true

            # e.g. "--help"
            elif [[ "${word}" == ${CLI_DSL_ARG_NAME_GLOB} ]] && \
                    [[ "${line}" =~ ^"${CLI_DSL_LITERAL_TAB}${word}" ]]; then
                in_argument_copy=false
                yield ${CLI_DSL_TOKEN_NAME} "${word#--}"

            # "--"
            elif [[ "${word}" == ${CLI_DSL_LITERAL_DASHDASH} ]]; then
                in_argument_copy=false
                yield ${CLI_DSL_TOKEN_DASHDASH}

            # e.g. "-h"
            elif [[ "${word}" == ${CLI_DSL_ARG_ALIAS_GLOB} ]]; then
                yield ${CLI_DSL_TOKEN_ALIAS} "${word#-}"

            # "[Required]"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_REQUIRED}" ]]; then
                yield ${CLI_DSL_TOKEN_REQUIRED}

            # "[Flag]"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_FLAG}" ]]; then
                yield ${CLI_DSL_TOKEN_FLAG}

            # "[List]"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_LIST}" ]]; then
                yield ${CLI_DSL_TOKEN_LIST}

            # "[Properties]"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_PROPERTIES}" ]]; then
                yield ${CLI_DSL_TOKEN_PROPERTIES}

            # "Regex:"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_REGEX}" ]]; then
                in_argument_copy=false
                yield ${CLI_DSL_TOKEN_REGEX}

            # "Default:"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_DEFAULT}" ]]; then
                in_argument_copy=false
                yield ${CLI_DSL_TOKEN_DEFAULT}

            # "values:"
            elif [[ "${word}" == "${CLI_DSL_LITERAL_VALUES}" ]]; then

                if [[ "${last_word}" == "${CLI_DSL_LITERAL_ALLOWED}" ]]; then
                    in_argument_copy=false
                    yield ${CLI_DSL_TOKEN_ALLOWED_VALUES}
                fi

            # elements; e.g. 'foo' of "Allowed values: foo, bar."
            elif [[ "${word}" == *, ]]; then
                yield ${CLI_DSL_TOKEN_VALUE_COMMA} "${word%,}"

            # last element; e.g. bar of "Allowed values: foo, bar."
            elif [[ "${word}" == *. ]]; then
                yield ${CLI_DSL_TOKEN_VALUE_PERIOD} "${word%.}"
                in_argument_copy=true
            fi
        done
    done

    in_argument_copy=false
    in_argument_header=true
    line_number=$(( line_number + 1 ))
    yield $CLI_DSL_TOKEN_EOF
}

cli::dsl::tokenize::self_test() (    
    diff <(cli sample kitchen-sink -h \
            | cli dsl tokenize \
        ) \
        <(cat <<-EoF
			ARGUMENTS 7 1 id
			NAME 8 1 id
			ALIAS 8 2 i
			ARGUMENTS 10 1 name
			NAME 11 1 name
			NAME 12 1 namespace
			ARGUMENTS 14 1 
			NAME 15 1 run-as
			NAME 17 1 fruit
			ALIAS 17 2 f
			DEFAULT 17 6 
			VALUE_PERIOD 17 7 banana
			ALLOWED_VALUES 18 1 
			VALUE_COMMA 18 2 orange
			VALUE_PERIOD 18 3 banana
			NAME 19 1 header
			REQUIRED 19 2 
			REGEX 19 5 
			VALUE_PERIOD 19 6 ^[A-Z][A-Za-z0-9_]*$
			NAME 20 1 dump
			ALIAS 20 2 d
			FLAG 20 3 
			NAME 21 1 my-list
			ALIAS 21 2 l
			LIST 21 3 
			NAME 22 1 my-props
			ALIAS 22 2 p
			PROPERTIES 22 3 
			DASHDASH 23 1 
			ARGUMENTS 28 1 
			NAME 29 1 help
			ALIAS 29 2 h
			FLAG 29 3 
			NAME 30 1 self-test
			FLAG 30 2 
			EOF 31 7 
			EoF
        )
)
