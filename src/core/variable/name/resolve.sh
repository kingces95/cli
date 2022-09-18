#! inline

CLI_IMPORT=(
    "cli core type get"
    "cli core type get-info"
    "cli core type unmodify"
)

cli::core::variable::name::resolve::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return a bash variable name given a bash variable and a string of fields.

Description
    Argument \$1 is the root uppercase bash variable name. Remaining arguments 
    are lower case field names. 

    ARG_TYPE is the type of the root bash variable. 

    REPLY is the resolved bash name.
    MAPFILE is the type of the resolved bash name.
EOF
}

cli::core::variable::name::resolve::main() {
    cli core variable parse ---source

    cli::core::variable::parse "$@"
    shift $(( ${#MAPFILE[@]} ))
    shift

    ARG_TYPE="${MAPFILE[@]}" \
        cli::core::variable::name::resolve "${REPLY}" "$@"

    echo "${MAPFILE[*]} ${REPLY}"
}

cli::core::variable::name::resolve() {
    local TYPE=( ${ARG_TYPE-} )
    [[ "${TYPE[@]}" ]] || cli::assert 'Missing type.'
   
    local NAME="${1-}"
    [[ "${NAME}" ]] || cli::assert 'Missing name.'
    [[ "${NAME}" =~ ${CLI_REGEX_GLOBAL_NAME} ]] || cli::assert "Bad bash name '${NAME}'."
    shift

    for i in "$@"; do

        cli::core::type::get_info "${TYPE[@]}"

        # builtin
        if ${REPLY_CLI_CORE_TYPE_IS_BUILTIN}; then
            
            # array
            if ${REPLY_CLI_CORE_TYPE_IS_ARRAY}; then
                (( $# <= 1 )) || cli::assert "Expected array index but got '$@'."

            # map
            elif ${REPLY_CLI_CORE_TYPE_IS_MAP}; then
                (( $# <= 1 )) || cli::assert "Expected map key but got '$@'."

            # scaler
            else
                (( $# == 0 )) || cli::assert "Scaler type '${TYPE}' has no field '$@'."
            fi

        # modified
        elif ${REPLY_CLI_CORE_TYPE_IS_MODIFIED}; then
            local -n ORDINAL_MAP=${NAME}
            [[ "${ORDINAL_MAP["$i"]+set}" == 'set' ]] \
                || cli::assert "Failed to resolve key '$i' in '${NAME}'."
            NAME=${NAME}_${ORDINAL_MAP["$i"]}

            cli::core::type::unmodify "${MAPFILE[@]}"
            TYPE=( ${MAPFILE[@]} )

        # udt
        else
            ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED} \
                || cli::assert "Expected user defined type but got '${TYPE[@]}'."

            cli::core::type::get "${REPLY}"
            local -n TYPE_REF="${REPLY}"

            if [[ ! "${TYPE_REF[$i]+set}" == 'set' ]]; then
                cli::assert "Field '$i' not found in '${TYPE}' fields: { ${!TYPE_REF[@]} }."
            fi

            TYPE=( ${TYPE_REF["$i"]} )
            NAME=${NAME}_${i^^}
        fi
    done

    MAPFILE=( "${TYPE[@]}" )
    REPLY="${NAME}"
}

cli::core::variable::name::resolve::self_test() {

    diff <(${CLI_COMMAND[@]} -- string VAR) - <<< 'string VAR'

    diff <(${CLI_COMMAND[@]} -- string VAR) - <<< 'string VAR'
    diff <(${CLI_COMMAND[@]} -- integer VAR) - <<< 'integer VAR'
    diff <(${CLI_COMMAND[@]} -- boolean VAR) - <<< 'boolean VAR'
    diff <(${CLI_COMMAND[@]} -- map VAR) - <<< 'map VAR'
    diff <(${CLI_COMMAND[@]} -- array VAR) - <<< 'array VAR'

    diff <(${CLI_COMMAND[@]} -- array VAR 0) - <<< 'array VAR'

    # map_of map_of integer
    (
        local -A VAR=(
            ['seq']=0
        )
        local -A VAR_0=(
            ['fib']=0
            ['pi']=1
        )
        local -A VAR_0_0=11235
        local -A VAR_0_1=3141
        local TYPE=( map_of map_of integer )

        diff <(${CLI_COMMAND[@]} -- "${TYPE[@]}" VAR) - <<< 'map_of map_of integer VAR'
        diff <(${CLI_COMMAND[@]} -- "${TYPE[@]}" VAR seq) - <<< 'map_of integer VAR_0'
        diff <(${CLI_COMMAND[@]} -- "${TYPE[@]}" VAR seq fib) - <<< 'integer VAR_0_0'
        diff <(${CLI_COMMAND[@]} -- "${TYPE[@]}" VAR seq pi) - <<< 'integer VAR_0_1'
    )

    # map_of array
    (
        local -A VAR=(
            ['seq']=0
        )
        local -a VAR_0=( 'fib' 'pi' )
        diff <(${CLI_COMMAND[@]} -- map_of array VAR seq) - <<< 'array VAR_0'
    )

    # udt
    (    
        local -A CLI_TYPE_VERSION=(
            ['major']=integer
            ['minor']=integer
        )
        local -A CLI_TYPE_METADATA=(
            ['allow']='map_of map'
            ['mmm']='map_of map_of map'
            ['positional']='boolean'
            ['version']='version'
        )

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

        diff <(${CLI_COMMAND[@]} -- metadata META allow color) - <<< 'map META_ALLOW_0'
        diff <(${CLI_COMMAND[@]} -- metadata META mmm a b) - <<< 'map META_MMM_0_0'
        diff <(${CLI_COMMAND[@]} -- metadata META positional) - <<< 'boolean META_POSITIONAL'
        diff <(${CLI_COMMAND[@]} -- metadata META version) - <<< 'version META_VERSION'
        diff <(${CLI_COMMAND[@]} -- metadata META version major) - <<< 'integer META_VERSION_MAJOR'
        diff <(${CLI_COMMAND[@]} -- metadata META version minor) - <<< 'integer META_VERSION_MINOR'
    )
}
