#!/usr/bin/env CLI_TOOL=cli bash-cli-part
cli::args::check::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Check an argument value is valid.

Description
    Given an argument value and associated metadata, fail if the value violates
    constraints specified by the metadata. The value can be a boolean, integer,
    or string. Elements and values of arrays and maps are passed one by one to 
    this function for validation.
    
    Positional arguments are:

        - name
        - value
        - type (boolean, integer, string)
        - required
        - regex
        - allowed values
        - min
        - max

    Empty metadata values imply no validation for that dimention of metadata.

Arguments
    --                       : 
EOF
    cat << EOF

Examples
    ${CLI_COMMAND[@]} -- value "hello world" 'string' true '[a-z ]*' '' '' ''
EOF
}

cli::args::check() {
    local name="${1-}"
    local value="${2-}"
    local type=${3:-'string'}
    local regex=${4:-}
    local -a allow=( ${5:-} )
    local min=${6:-0}
    local max=${7:-1000000}

    # type
    case ${type} in
        'string') ;;
        'integer') regex='^[-]?[0-9]+$' ;;
        'boolean') regex='^true$|^false$|^$' ;;
        *) cli::stderr::fail "Unexpected argument type '${type}' for argument '--${name}'."
    esac

    # regex
    if [[ -n "${regex}" ]]; then
        if [[ ! "${value}" =~ ${regex} ]]; then
            cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                "passed to command '${CLI_COMMAND[@]}'." \
                "Expected a value that matches regex '${regex}'."
        fi
    fi

    # allow
    if (( ${#allow[@]} > 0 )); then

        # convert array of allowed value into a set
        local -A set
        local element
        for element in "${allow[@]}"; do
            set[$element]="true"
        done

        if [[ -z "${value}" || -z ${set[${value}]+set} ]]; then
            cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                "passed to command '${CLI_COMMAND[@]}'." \
                "Expected a value in the set { "${!set[@]}" }."
        fi
    fi

    # max/min
    case ${type} in
        'string') 
            if (( ${#value} < ${min} )); then
                cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                    "passed to command '${CLI_COMMAND[@]}'." \
                    "Expected a value whose length is at least ${min}."
            fi
            if (( ${#value} > ${max} )); then
                cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                    "passed to command '${CLI_COMMAND[@]}'." \
                    "Expected a value whose length is no more than ${max}."
            fi
            ;;
        'integer') regex='[-]?[0-9]+' 
            if (( ${value} < ${min} )); then
                cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                    "passed to command '${CLI_COMMAND[@]}'." \
                    "Expected a value that is at least ${min}."
            fi
            if (( ${value} > ${max} )); then
                cli::stderr::fail "Unexpected value '${value}' for argument '--${name}'" \
                    "passed to command '${CLI_COMMAND[@]}'." \
                    "Expected a value that is no more than ${max}."
            fi
        ;;
    esac
}

cli::args::check::self_test() (
    ${CLI_COMMAND[@]} -- myname myvalue
    ${CLI_COMMAND[@]} -- myname true 'boolean'
    ${CLI_COMMAND[@]} -- myname false 'boolean'
    ${CLI_COMMAND[@]} -- myname '' 'boolean'
    ${CLI_COMMAND[@]} -- myname myvalue 'string' '.*' 'myvalue myothervalue' 0 100
    ${CLI_COMMAND[@]} -- myname myothervalue 'string' '.*' 'myvalue myothervalue' 0 100

    test() {
        ! { set -m; (cli::args::check "$@") } 2>&1 1>/dev/stderr || cli::assert
    }

    diff <(test myname 'two' 'integer') <(echo \
        "Unexpected value 'two' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value that matches regex '^[-]?[0-9]+$'."
    ) || cli::assert

    diff <(test myname 'ok' 'boolean') <(echo \
        "Unexpected value 'ok' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value that matches regex '^true$|^false$|^$'."
    ) || cli::assert

    diff <(test myname Foo string "^[a-z]$") <(echo \
        "Unexpected value 'Foo' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value that matches regex '^[a-z]$'."
    ) || cli::assert

    diff <(test myname Foo string '' "Bar") <(echo \
        "Unexpected value 'Foo' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value in the set { Bar }."
    ) || cli::assert

    diff <(test myname Foo string '' '' 10) <(echo \
        "Unexpected value 'Foo' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value whose length is at least 10."
    ) || cli::assert

    diff <(test myname Foo string '' '' 0 2) <(echo \
        "Unexpected value 'Foo' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value whose length is no more than 2."
    ) || cli::assert

    diff <(test myname 5 integer '' '' 10) <(echo \
        "Unexpected value '5' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value that is at least 10."
    ) || cli::assert

    diff <(test myname 5 integer '' '' 0 2) <(echo \
        "Unexpected value '5' for argument '--myname' passed to command '${CLI_COMMAND[@]}'." \
        "Expected a value that is no more than 2."
    ) || cli::assert
)
