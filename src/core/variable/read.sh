#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable put
cli::source cli core variable declare

cli::core::variable::read::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Read and declare a core variable for a record.

Description
    Arguments \$1 - \$n are type of a variable followed by a base name. The variable
    is declared and then populated by records read from stdin.

    Each record is a path followed by the value (or key/value if the type is a map).
EOF
}

cli::core::variable::read::main() {
    cli core variable parse ---source

    cli::core::variable::parse::inline "$@"
    local NAME=${REPLY}
    local TYPE="${MAPFILE[*]}"

    ARG_TYPE="${TYPE}" \
        cli::core::variable::declare::inline "${NAME}"

    cli::core::variable::read::inline "${NAME}"

    cli::dump "${NAME}" "${NAME}_*"
}

cli::core::variable::read::inline() {
    local ARG_SCOPE=${ARG_SCOPE-'CLI_SCOPE'}
    local NAME="$1"

    while read -a MAPFILE; do
        cli::core::variable::put::inline "${NAME}" "${MAPFILE[@]}"
    done
}

cli::core::variable::read::self_test() {
    local ARG_SCOPE='SCOPE'

    escaping() {
        local -A SCOPE=()
       
        # string
        diff <( ${CLI_COMMAND[@]} -- string MY_STRING <<< 'Hello\ world!' ) - \
            <<< 'declare -- MY_STRING="Hello world!"'

        # array
        diff <( ${CLI_COMMAND[@]} -- array MY_ARRAY <<< 'a\ b\ c' ) - \
            <<< 'declare -a MY_ARRAY=([0]="a b c")'

        # map
        diff <( ${CLI_COMMAND[@]} -- map MY_MAP <<< 'a b\ c' ) - \
            <<< 'declare -A MY_MAP=([a]="b c" )'
    }

    builtin() {
        local -A SCOPE=()

        # string
        diff <( ${CLI_COMMAND[@]} -- string MY_STRING <<< 'Hello' ) - \
            <<< 'declare -- MY_STRING="Hello"'

        # boolean
        diff <( ${CLI_COMMAND[@]} -- boolean MY_BOOLEAN <<< true ) - \
            <<< 'declare -- MY_BOOLEAN="true"'

        diff <( ${CLI_COMMAND[@]} -- boolean MY_BOOLEAN <<< '' ) - \
            <<< 'declare -- MY_BOOLEAN="true"'

        # integer
        diff <( ${CLI_COMMAND[@]} -- integer MY_INTEGER <<< 42 ) - \
            <<< 'declare -i MY_INTEGER="42"'

        # array
        diff <( ${CLI_COMMAND[@]} --- array MY_ARRAY <<< a > /dev/null
                ${CLI_COMMAND[@]} -- array MY_ARRAY <<< b; ) - \
            <<< 'declare -a MY_ARRAY=([0]="a" [1]="b")'

        # map
        diff <( ${CLI_COMMAND[@]} -- map MY_MAP <<< 'a 0' ) - \
            <<< 'declare -A MY_MAP=([a]="0" )'
    }

    builtin_default() {
        local -A SCOPE=()

        # string
        diff <( ${CLI_COMMAND[@]} -- string MY_STRING < /dev/null ) - \
            <<< 'declare -- MY_STRING=""'

        # boolean
        diff <( ${CLI_COMMAND[@]} -- boolean MY_BOOLEAN < /dev/null ) - \
            <<< 'declare -- MY_BOOLEAN="false"'

        # integer
        diff <( ${CLI_COMMAND[@]} --- integer MY_INTEGER < /dev/null ) - \
            <<< 'declare -i MY_INTEGER="0"'

        # array
        diff <( ${CLI_COMMAND[@]} --- array MY_ARRAY < /dev/null ) - \
            <<< 'declare -a MY_ARRAY=()'

        # map
        diff <( ${CLI_COMMAND[@]} --- map MY_MAP < /dev/null) - \
            <<< 'declare -A MY_MAP=()'
    }

    double_indirect() {
        local -A SCOPE=()
  
        diff <( ${CLI_COMMAND[@]} -- map_of map_of string MY_MAP_OF_MAP_OF_STRING <<< 'x y Hello' ) <(
            echo 'declare -A MY_MAP_OF_MAP_OF_STRING=([x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_OF_STRING_0=([y]="0" )'
            echo 'declare -- MY_MAP_OF_MAP_OF_STRING_0_0="Hello"'
        )
    }

    indirect() {
        local -A SCOPE=()

        # string
        diff <( ${CLI_COMMAND[@]} -- map_of string MY_MAP_OF_STRING <<< 'x Hello' ) <(
            echo 'declare -A MY_MAP_OF_STRING=([x]="0" )'
            echo 'declare -- MY_MAP_OF_STRING_0="Hello"'
        )

        # boolean
        diff <( ${CLI_COMMAND[@]} -- map_of boolean MY_MAP_OF_BOOLEAN <<< 'x true' ) <(
            echo 'declare -A MY_MAP_OF_BOOLEAN=([x]="0" )'
            echo 'declare -- MY_MAP_OF_BOOLEAN_0="true"'
        )

        # integer
        diff <( ${CLI_COMMAND[@]} -- map_of integer MY_MAP_OF_INTEGER <<< 'x 42' ) <(
            echo 'declare -A MY_MAP_OF_INTEGER=([x]="0" )'
            echo 'declare -i MY_MAP_OF_INTEGER_0="42"'
        )

        # array
        diff <( 
            ${CLI_COMMAND[@]} --- map_of array MY_MAP_OF_ARRAY <<< 'x a\ b' > /dev/null
            ${CLI_COMMAND[@]} -- map_of array MY_MAP_OF_ARRAY <<< 'x c' 
        ) <(
            echo 'declare -A MY_MAP_OF_ARRAY=([x]="0" )'
            echo 'declare -a MY_MAP_OF_ARRAY_0=([0]="a b" [1]="c")'
        )

        # map
        diff <( 
            ${CLI_COMMAND[@]} --- map_of map MY_MAP_OF_MAP <<< 'x a 0' > /dev/null
            ${CLI_COMMAND[@]} --- map_of map MY_MAP_OF_MAP <<< 'x b 1' > /dev/null 
            ${CLI_COMMAND[@]} --- map_of map MY_MAP_OF_MAP <<< 'y a 0' > /dev/null 
            ${CLI_COMMAND[@]} -- map_of map MY_MAP_OF_MAP <<< 'y a' 
        ) <(
            echo 'declare -A MY_MAP_OF_MAP=([y]="1" [x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_0=([b]="1" [a]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_1=([a]="" )'
        )
    }

    indirect_default() {
        local -A SCOPE=()

        # string
        diff <( ${CLI_COMMAND[@]} -- map_of string MY_MAP_OF_STRING <<< 'x' ) <( \
            echo 'declare -A MY_MAP_OF_STRING=([x]="0" )'
            echo 'declare -- MY_MAP_OF_STRING_0=""'
        )

        # boolean
        diff <( ${CLI_COMMAND[@]} -- map_of boolean MY_MAP_OF_BOOLEAN <<< 'x' ) <( \
            echo 'declare -A MY_MAP_OF_BOOLEAN=([x]="0" )'
            echo 'declare -- MY_MAP_OF_BOOLEAN_0="true"'
        )

        # integer
        diff <( ${CLI_COMMAND[@]} -- map_of integer MY_MAP_OF_INTEGER <<< 'x' ) <( \
            echo 'declare -A MY_MAP_OF_INTEGER=([x]="0" )'
            echo 'declare -i MY_MAP_OF_INTEGER_0="0"'
        )

        # array
        diff <( 
            ${CLI_COMMAND[@]} -- map_of array MY_MAP_OF_ARRAY <<< 'x'
        ) <(
            echo 'declare -A MY_MAP_OF_ARRAY=([x]="0" )'
            echo 'declare -a MY_MAP_OF_ARRAY_0=()'
        )

        # map
        diff <( 
            ${CLI_COMMAND[@]} --- map_of map MY_MAP_OF_MAP <<< 'x a' > /dev/null
            ${CLI_COMMAND[@]} --- map_of map MY_MAP_OF_MAP <<< 'x b' > /dev/null 
            ${CLI_COMMAND[@]} -- map_of map MY_MAP_OF_MAP <<< 'y a' 
        ) <( \
            echo 'declare -A MY_MAP_OF_MAP=([y]="1" [x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_0=([b]="" [a]="" )'
            echo 'declare -A MY_MAP_OF_MAP_1=([a]="" )'
        )
    }

    udt() {

        declare -A CLI_TYPE_VERSION=(
            ['major']='integer' 
            ['minor']='integer'
        )

        # indirect
        diff <( 
            local -A SCOPE=()
            ${CLI_COMMAND[@]} --- map_of version MY_MAP_OF_VERSION <<< 'x major 1' > /dev/null
            ${CLI_COMMAND[@]} -- map_of version MY_MAP_OF_VERSION <<< 'x minor 2'
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="1"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="2"'
        )

        # indirect no key
        diff <( 
            local -A SCOPE=()
            ${CLI_COMMAND[@]} -- map_of version MY_MAP_OF_VERSION < /dev/null
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=()'
        )

        # indirect key but no field
        diff <( 
            local -A SCOPE=()
            ${CLI_COMMAND[@]} -- map_of version MY_MAP_OF_VERSION <<< 'x'
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="0"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="0"'
        )

        # indirect default
        diff <( 
            local -A SCOPE=()
            ${CLI_COMMAND[@]} --- map_of version MY_MAP_OF_VERSION <<< 'x major 1' > /dev/null
            ${CLI_COMMAND[@]} -- map_of version MY_MAP_OF_VERSION <<< 'x major'
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="0"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="0"'
        )

        # direct
        declare -A CLI_TYPE_UDT=(
            ['positional']='boolean' 
            ['allow']='map_of map' 
            ['version']='version'
        )
        diff <( 
            local -A SCOPE=()
            ${CLI_COMMAND[@]} --- udt MY_UDT <<< 'positional true' > /dev/null
            ${CLI_COMMAND[@]} --- udt MY_UDT <<< 'version minor 2' > /dev/null
            ${CLI_COMMAND[@]} --- udt MY_UDT <<< 'version major 1' > /dev/null
            ${CLI_COMMAND[@]} --- udt MY_UDT <<< 'allow color white' > /dev/null
            ${CLI_COMMAND[@]} --- udt MY_UDT <<< 'allow color black'
        ) <(
            echo 'declare -A MY_UDT_ALLOW=([color]="0" )' 
            echo 'declare -A MY_UDT_ALLOW_0=([black]="" [white]="" )' 
            echo 'declare -- MY_UDT_POSITIONAL="true"'
            echo 'declare -i MY_UDT_VERSION_MAJOR="1"' 
            echo 'declare -i MY_UDT_VERSION_MINOR="2"'
        )
    }

    missing_field() {

        # indirect
        set +e
        declare -A CLI_TYPE_VERSION=(['major']='integer' ['minor']='integer')
        declare -A MY_MAP_OF_VERSION=()
        declare -p \
            CLI_TYPE_VERSION \
            MY_MAP_OF_VERSION \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x major 1 \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x minor 2 \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x missing 3 \
              2>&1 >/dev/null \
            | assert::error_message "Field 'missing' not found in 'version' fields: { minor major }."
        assert::failed
        set -e
    }

    bad_value() {
        set +e
        declare MY_BOOLEAN
        declare -p MY_BOOLEAN \
            | ${CLI_COMMAND[@]} -s --type boolean --name MY_BOOLEAN -- 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'bad' to boolean 'MY_BOOLEAN'." \
                "'bad' does not match regex '^$|^true$|^false$'."
        assert::failed

        declare -i MY_INTEGER
        declare -p MY_INTEGER \
            | ${CLI_COMMAND[@]} -s --type integer --name MY_INTEGER -- 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'bad' to integer 'MY_INTEGER'." \
                "'bad' does not match regex '^$|^[-]?[0-9]+$'."
        assert::failed

        declare -A MY_MAP
        declare -p MY_MAP \
            | ${CLI_COMMAND[@]} -s --type map --name MY_MAP -- '' 'val' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to use empty key to assign 'val' to map 'MY_MAP'." \
                "'' does not match regex '.'."
        assert::failed
        set -e
    }

    too_many_values() {
        set +e
        declare MY_BOOLEAN
        declare -p MY_BOOLEAN \
            | ${CLI_COMMAND[@]} -s --type boolean --name MY_BOOLEAN -- 'true' 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'true' to boolean 'MY_BOOLEAN'." \
                "Expected a record with one or no fields, but got 'true bad'."
        assert::failed

        declare -A MY_MAP
        declare -p MY_MAP \
            | ${CLI_COMMAND[@]} -s --type map --name MY_MAP -- 'key' 'value' 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign value 'value' to key 'key' in map 'MY_MAP'." \
                "Expected a record with two or fewer fields, but got 'key value bad'."
        assert::failed
        set -e
    }

    escaping
    builtin
    builtin_default

    indirect
    double_indirect
    indirect_default

    udt

    # bad_value
    # too_many_values
    # missing_field
}
