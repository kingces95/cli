CLI_IMPORT=(
    "cli bash write"
    "cli core type get"
    "cli core variable get-info"
    "cli core variable resolve"
)

cli::core::variable::write::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Write a variable's fields as a sequence of records.

Description
    Argument \$1 is the variable whose fields are to be copied to stdout
    as records consisting of field names followed by the field value.
EOF
    cat << EOF

Examples
    For example, writing a variable VAR of type 'metadata' defined as 
    
        CLI_TYPE_METADATA=(
            [positional]=boolean
            [allow]='map_of map'
        )
        
    where 'positional' is 'true' and 'allow' is has a key 'color' which points at a 
    map whose keys are 'black' and 'white' and whose values are empty:

        VAR_POSITIONAL=true
        VAR_ALLOW=( [0]='color' )
        VAR_ALLOW_0=(
            [black]=
            [white]=
        )

    would produce the following records: 

        allow color black
        allow color white
        positional true
EOF
}

cli::core::variable::write() {
    local ARG_SCOPE=${ARG_SCOPE-'CLI_SCOPE'}
    local NAME="${1-}"

    # check NAME in ARG_SCOPE
    cli::core::variable::get_info "${NAME}" \
        || cli::assert "Variable '${NAME}' not found in scope."
    local TYPE="${MAPFILE[*]}"

    # private stack
    local PREFIX_NAME=CLI_CORE_VARIABLE_WRITE_PREFIX
    local -n PREFIX=CLI_CORE_VARIABLE_WRITE_PREFIX

    # leaf
    if ${REPLY_CLI_CORE_VARIABLE_IS_BUILTIN}; then
        local -n REF=${NAME}

        # boolean
        if ${REPLY_CLI_CORE_VARIABLE_IS_BOOLEAN}; then

            if ${REF}; then
                cli::bash::write "${PREFIX[@]}"
            fi

        # scaler
        elif ${REPLY_CLI_CORE_VARIABLE_IS_SCALER}; then
            cli::bash::write "${PREFIX[@]}" "${REF}"

        # array
        elif ${REPLY_CLI_CORE_VARIABLE_IS_ARRAY}; then
            for VALUE in "${REF[@]}"; do
                cli::bash::write "${PREFIX[@]}" "${VALUE}"
            done

        # map
        else
            ${REPLY_CLI_CORE_VARIABLE_IS_MAP} || cli::assert
            for KEY in ${!REF[@]}; do
                cli::bash::write "${PREFIX[@]}" "${KEY}" "${REF[$KEY]}"
            done
        fi

    else
        local -a SEGMENTS

        # anonymous
        if ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED}; then
            local -n ORDINALS_REF=${NAME}
            SEGMENTS=( "${!ORDINALS_REF[@]}" )

        # udt
        else
            ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED} || cli::assert
            local USER_DEFINED_TYPE="${REPLY}"

            cli::core::type::get "${USER_DEFINED_TYPE}"

            local -n TYPE_REF="${REPLY}"
            SEGMENTS=( "${!TYPE_REF[@]}" )
        fi

        local -a PREFIX_COPY=( "${PREFIX[@]}" )

        local SEGMENT
        for SEGMENT in "${SEGMENTS[@]}"; do
            local -a CLI_CORE_VARIABLE_WRITE_PREFIX=( "${PREFIX_COPY[@]}" "${SEGMENT}" )
            cli::core::variable::resolve "${NAME}" "${SEGMENT}"
            cli::core::variable::write "${REPLY}"
        done
    fi
}

cli::core::variable::write::self_test() {
    ARG_SCOPE='SCOPE'

    # builtin
    local -A SCOPE=(
        ['MY_STRING']='string'
        ['MY_INTEGER']='integer'
        ['MY_BOOLEAN']='boolean'
        ['MY_MAP']='map'
        ['MY_ARRAY']='array'
    )

    # string
    local MY_STRING='Hello World!'
    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'Hello\ World!'

    # integer
    local -i MY_INTEGER=42
    diff <(${CLI_COMMAND[@]} -- MY_INTEGER) - <<< '42'

    # boolean true
    local MY_BOOLEAN=true
    diff <(${CLI_COMMAND[@]} -- MY_BOOLEAN) - <<< ''

    # boolean false
    local MY_BOOLEAN=false
    diff <(${CLI_COMMAND[@]} -- MY_BOOLEAN) /dev/null

    # array
    local -a MY_ARRAY=( 'a a b a' )
    diff <(${CLI_COMMAND[@]} -- MY_ARRAY) - <<< 'a\ a\ b\ a'

    # array
    local -a MY_ARRAY=( a a b a )
    diff <(${CLI_COMMAND[@]} -- MY_ARRAY) <(
        echo a
        echo a
        echo b
        echo a
    )

    # map
    local -A MY_MAP=( [key]=value [element]= )
    diff <(${CLI_COMMAND[@]} -- MY_MAP | sort) <(
        echo "element"
        echo key value
    )

    # map_of map
    local -A SCOPE=(
        ['MOD_MAP']='map_of map'
        ['MOD_MAP_0']='map'
    )
    local -A MOD_MAP=(
        ['seq']=0
    )
    local -A MOD_MAP_0=(
        ['pi']=3141
        ['fib']=11235
    )
    diff <(${CLI_COMMAND[@]} -- MOD_MAP | sort) <(
        echo seq fib 11235
        echo seq pi 3141
    )
    
    # map_of map_of integer
    local -A SCOPE=(
        ['MOD_MOD_INTEGER']='map_of map_of integer'
        ['MOD_MOD_INTEGER_0']='map_of integer'
        ['MOD_MOD_INTEGER_0_0']='integer'
        ['MOD_MOD_INTEGER_0_1']='integer'
    )
    local -A MOD_MOD_INTEGER=(
        ['seq']=0
    )
    local -A MOD_MOD_INTEGER_0=(
        ['fib']=0
        ['pi']=1
    )
    local -A MOD_MOD_INTEGER_0_0=11235
    local -A MOD_MOD_INTEGER_0_1=3141
    diff <(${CLI_COMMAND[@]} -- MOD_MOD_INTEGER | sort) <(
        echo seq fib 11235
        echo seq pi 3141
    )

    # map_of array
    local -A SCOPE=(
        ['MOD_ARRAY']='map_of array'
        ['MOD_ARRAY_0']='array'
    )
    local -A MOD_ARRAY=(
        ['seq']=0
    )
    local -a MOD_ARRAY_0=( 'fib' 'pi' )
    diff <(${CLI_COMMAND[@]} -- MOD_ARRAY) <(
        echo seq fib
        echo seq pi
    )

    # udt
    local -A SCOPE=(
        ['META']='metadata'
        ['META_NEVER']='boolean'
        ['META_POSITIONAL']='boolean'
        ['META_VERSION']='version'
        ['META_VERSION_MAJOR']='integer'
        ['META_VERSION_MINOR']='integer'
        ['META_ALLOW']='map_of map'
        ['META_ALLOW_0']='map'
        ['META_MMM']='map_of map_of map'
        ['META_MMM_0']='map_of map'
        ['META_MMM_0_0']='map'
    )
    local -A CLI_TYPE_VERSION=(
        ['major']=integer
        ['minor']=integer
    )
    local -A CLI_TYPE_METADATA=(
        ['allow']='map_of map'
        ['mmm']='map_of map_of map'
        ['positional']='boolean'
        ['never']='boolean'
        ['version']='version'
    )

    local META_NEVER=false
    local META_POSITIONAL=true
    local -i META_VERSION_MAJOR=1
    local -i META_VERSION_MINOR=2
    local -A META_ALLOW=(
        ['color']=0
    )
    local -A META_ALLOW_0=(
        ['black']=
        ['white']=
    )
    local -A META_MMM=(
        ['a']=0
    )
    local -A META_MMM_0=(
        ['b']=0
    )
    local -A META_MMM_0_0=(
        ['c']='d'
    )

    diff <(${CLI_COMMAND[@]} -- META | sort) <(
        echo 'allow color black' 
        echo 'allow color white' 
        echo 'mmm a b c d' 
        echo 'positional' 
        echo 'version major 1' 
        echo 'version minor 2'
    )
}
