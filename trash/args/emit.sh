#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli core variable declare"
    "cli core variable put"
    "cli core variable read"
    "cli core variable write"
)

cli::args::emit::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Assign command line values to variables and print the variables.

Description
    Consume a stream generated by 'cli args emit' and generate a sequence of declare 
    statements for each named argument.

Arguments
    --                       : 1) Records (name, type) for named arguments
                               2) Records () 
EOF
}

cli::args::emit::main() {   
    local _ARG_ARGS
    local _ARG_META
    local _ARG_TYPE
    local _ARG_PREFIX
    local _ARG_BASH_NAME

    # load parameter types
    cli::declare 'map' META
    cli::read META < "${1-/dev/null}"
    # cli::print META

    # e.g. load CLI_TYPE_CLI_GROUP_0
    cli::declare 'map' CLI_TYPE_GROUP
    cli::read CLI_TYPE_GROUP < "${2-/dev/null}"
    # declare -p CLI_TYPE_GROUP

    # load map of parameter names -> bash names; pre-computed during bgen
    cli::declare 'map' BASH_NAMES
    cli::read BASH_NAMES < "${3-/dev/null}"
    # declare -p BASH_NAMES

    # load ast of arguments
    cli::declare 'cli_args' ARGS
    cli::read ARGS
    # cli::print ARGS

    _ARG_ARGS='ARGS' \
    _ARG_META='META' \
    _ARG_TYPE='GROUP' \
    _ARG_BASH_NAME='BASH_NAMES' \
    _ARG_PREFIX='ARG'
        cli::args::emit
}

cli::args::emit() {
    # use_ARG_* instead of ARG_* to avoid conflicts (e.g. _ARG_TYPE)
    : ${_ARG_ARGS?} # e.g. CLI_ARGS
    : ${_ARG_META?} # e.g. CLI_META_GROUP_0_TYPE (map: field -> type)
    : ${_ARG_TYPE?} # e.g. CLI_TYPE_GROUP_0
    : ${_ARG_BASH_NAME?} # e.g. CLI_META_BASH_NAME
    : ${_ARG_PREFIX?} # e.g. ARG

    local -n META_REF=${_ARG_META}
    local -n ARGS_NAMED_REF=${_ARG_ARGS}_NAMED
    local -n BASH_NAMES_REF=${_ARG_BASH_NAME}

    # declare -p _ARG_TYPE _ARG_PREFIX > /dev/stderr
    # cli::print 'CLI_META'
    # cli::dump 'CLI_TYPE_*'
    # declare -p CLI_TYPE_CLI_GROUP_0_TYPE > /dev/stderr

    # initialize variable with values (e.g. _ARG_SELF_TEST=true)

    local name
    for name in "${!META_REF[@]}"; do
        local type=${META_REF[${name}]}
        local bash_name=${BASH_NAMES_REF[${name}]}
        local variable=${_ARG_PREFIX}_${bash_name^^}
        local -n variable_ref="${variable}"

        if [[ -n "${ARGS_NAMED_REF[$name]+set}" ]]; then
            # copy value (e.g. arg_help=true)
            local -n value_ref="${_ARG_ARGS}_NAMED_${ARGS_NAMED_REF[${name}]}"
            local value="${value_ref[0]}"

            case ${type} in
                'boolean') 
                    # boolean has implicit value of true
                    if [[ -z "${value}" ]]; then 
                        value=true
                    fi 
                    ;;

                'array') 
                    variable_ref=( "${value_ref[@]}" ) 
                    continue
                    ;;

                'map')
                    for pair in "${value_ref[@]}"; do
                        variable_ref[${pair%%=*}]="${pair#*=}"
                    done
                    continue
                    ;;
            esac

            # string
            variable_ref="${value}"
        fi
    done
}

cli::args::emit::self_test() {

    # ${CLI_COMMAND[@]} < /dev/null \
    #     | assert::pipe_records_eq

    cli args tokenize -- --id 42 -f orange -h --header Foo --my-list a b --my-props a=x b=y -- a0 a1 \
        | cli args parse -- <({
                cli sample kitchen-sink ---load \
                    | awk '$1 == "alias" { $1=""; print }'
            }) \
        | cli args initialize -- <({
                cli sample kitchen-sink ---load \
                    | awk '$1 != "alias" && $1 != "bash_name" { $1=""; print }' \
                    | awk '$1 == "id" { $1=""; print }'
            }) \
        | ${CLI_COMMAND[@]} -- <({
                cli sample kitchen-sink ---load \
                    | awk '$1 != "alias" { $1=""; print }' \
                    | awk '$1 =="id" && $2 == "type" { print $3, $4 }'
            }) <({
                source <(cli sample kitchen-sink ---bgen | grep CLI_META_GROUP_0_TYPE)
                for field in ${!CLI_META_GROUP_0_TYPE[@]}; do
                    echo ${field} "${CLI_META_GROUP_0_TYPE[${field}]}"
                done
            }) <({
                source <(cli sample kitchen-sink ---bgen | grep CLI_META_BASH_NAME)
                for field in ${!CLI_META_BASH_NAME[@]}; do
                    echo ${field} "${CLI_META_BASH_NAME[${field}]}"
                done
            }) 
        #     \
        # | sort 
        # \
        # | assert::pipe_records_eq \
        #     "declare -- _ARG_DUMP=\"false\"" \
        #     "declare -- _ARG_FRUIT=\"orange\"" \
        #     "declare -- _ARG_HEADER=\"Foo\"" \
        #     "declare -- _ARG_HELP=\"true\"" \
        #     "declare -- _ARG_ID=\"42\"" \
        #     "declare -- _ARG_RUN_AS=\"\"" \
        #     "declare -- _ARG_SELF_TEST=\"false\"" \
        #     "declare -A _ARG_MY_PROPS=([b]=\"y\" [a]=\"x\" )" \
        #     "declare -a _ARG_MY_LIST=([0]=\"a\" [1]=\"b\")"
}
