alias fd-test-main="nix::test::pipeline::main"
alias fd-test-find="nix::test::pipeline::spy nix::test::pipeline::find cat"
alias fd-test-expand-file="nix::test::pipeline::spy nix::test::pipeline::expand::file a4f"
alias fd-test-expand-line="nix::test::pipeline::spy nix::test::pipeline::expand::line a4f"
alias fd-test-expand-resource="nix::test::pipeline::spy nix::test::pipeline::expand::resource a6f"
alias fd-test-override="nix::test::pipeline::spy nix::test::pipeline::override a5f"
alias fd-test-sort="nix::test::pipeline::spy nix::test::pipeline::sort a5f"
alias fd-test-program="nix::test::pipeline::spy nix::test::pipeline::program a3f"
alias fd-test-activations="nix::test::pipeline::spy nix::test::pipeline::activations a6f"
alias fd-test-declare="nix::test::pipeline::spy nix::test::pipeline::declare cat"
alias fd-test-reclamation="nix::test::pipeline::spy nix::test::pipeline::reclamation a3f"
alias fd-test-expand-assemble="nix::test::pipeline::spy nix::test::pipeline::expand::assemble a3f"
alias fd-test-expand-secure="nix::test::pipeline::spy nix::test::pipeline::expand::secure a3f"
alias fd-test-expand-environment="nix::test::pipeline::spy nix::test::pipeline::expand::environment a3f"
alias fd-test-expand-secret="nix::test::pipeline::spy nix::test::pipeline::expand::secret a3f"
alias fd-test-expand-secret-id="nix::test::pipeline::spy nix::test::pipeline::expand::secret_id a3f"
alias fd-test-expand-disband="nix::test::pipeline::spy nix::test::pipeline::expand::disband a3f"
alias fd-test-expand-grant="nix::test::pipeline::spy nix::test::pipeline::expand::grant a3f"
alias fd-test-expand-nominate="nix::test::pipeline::spy nix::test::pipeline::expand::nominate a3f"
alias fd-test-expand-ref="nix::test::pipeline::spy nix::test::pipeline::expand::ref a3f"
alias fd-test-resolve-pointer="nix::test::pipeline::spy nix::test::pipeline::resolve::pointer a3f"
alias fd-test-resolve-context="nix::test::pipeline::spy nix::test::pipeline::resolve::context a3f"
alias fd-test-resolve-persona="nix::test::pipeline::spy nix::test::pipeline::resolve::persona a3f"
alias fd-test-trim-group="nix::test::pipeline::spy nix::test::pipeline::trim::group a3f"
alias fd-test-emit="nix::test::pipeline::spy nix::test::pipeline::emit cat"

nix::test::pipeline::spy() {
    local STAGE="$1"
    shift

    local FORMAT="$1"
    shift

    NIX_TEST_SPY="${STAGE}" \
        nix::test::pipeline::main "$@" \
        | eval "${FORMAT}"
}

nix::test::pipeline::main() (
    exec 3>&1

    local SPY="nix::spy NIX_TEST_SPY"
    local PROGRAM=$(mktemp)
    local ACTIVATIONS=$(mktemp)

    if ! nix::fs::walk 'tst' "$@" \
        | ${SPY} nix::test::pipeline::find \
        | ${SPY} nix::test::pipeline::expand::file \
        | ${SPY} nix::test::pipeline::expand::line \
        | ${SPY} nix::test::pipeline::expand::resource \
        | ${SPY} nix::test::pipeline::override \
        | ${SPY} nix::test::pipeline::sort \
        | ${SPY} nix::test::pipeline::program \
        > "${PROGRAM}"
    then
        return
    fi

    if ! ${SPY} nix::test::pipeline::activations \
        < "${PROGRAM}" \
        > "${ACTIVATIONS}"
    then
        return
    fi

    if ! ${SPY} nix::test::pipeline::declare \
        < "${ACTIVATIONS}" \
        > /dev/null
    then
        return
    fi

    cat "${PROGRAM}" \
        | ${SPY} nix::test::pipeline::reclamation "${ACTIVATIONS}" \
        | ${SPY} nix::test::pipeline::expand::assemble \
        | ${SPY} nix::test::pipeline::expand::secure \
        | ${SPY} nix::test::pipeline::expand::environment \
        | ${SPY} nix::test::pipeline::expand::secret \
        | ${SPY} nix::test::pipeline::expand::secret_id \
        | ${SPY} nix::test::pipeline::expand::disband \
        | ${SPY} nix::test::pipeline::expand::grant \
        | ${SPY} nix::test::pipeline::expand::nominate \
        | ${SPY} nix::test::pipeline::expand::ref \
        | ${SPY} nix::test::pipeline::resolve::pointer \
        | ${SPY} nix::test::pipeline::resolve::context \
        | ${SPY} nix::test::pipeline::resolve::persona \
        | ${SPY} nix::test::pipeline::trim::group \
        | ${SPY} nix::test::pipeline::emit

    rm "${ACTIVATIONS}"
    rm "${PROGRAM}"
)

nix::test::pipeline::find() {
    nix::record::prepend 'file'
}

nix::test::path::info() {
    NIX_TEST_INFO_NAME_REPLY=
    NIX_TEST_INFO_ENTITY_REPLY=
    NIX_TEST_INFO_RESOURCE_REPLY=
    NIX_TEST_INFO_PARENT_REPLY=

    # ./my-vnet/my-subnet/subnet
    local PTH="$1"

    nix::path::info "${PTH}"

    local FILE_NAME="${NIX_PATH_INFO_FILE_NAME_REPLY}"
    local DIR_NAME="${NIX_PATH_INFO_DIR_NAME_REPLY}"
    local PARENT_DIR_NAME="${NIX_PATH_INFO_DIR_PARTS_REPLY[1]}"

    NIX_TEST_INFO_NAME_REPLY="${DIR_NAME}"      # my-subnet
    NIX_TEST_INFO_ENTITY_REPLY="${FILE_NAME}"   # subnet

    # skip non-entities (e.g. user)
    if ! nix::bash::map::test NIX_AZURE_RESOURCE "${FILE_NAME}"; then
        return
    fi

    # my-subnet
    NIX_TEST_INFO_RESOURCE_REPLY="${FILE_NAME}"

    # check for parent
    if nix::bash::map::test NIX_AZURE_RESOURCE_PARENT \
        "${NIX_TEST_INFO_RESOURCE_REPLY}"; then

        # myvent
        NIX_TEST_INFO_PARENT_REPLY="${PARENT_DIR_NAME}"    
    fi
}

nix::test::pipeline::expand::file() {
    local FILE PTH
    while read -r FILE PTH; do
        nix::test::path::info "${PTH}"

        local NAME="${NIX_TEST_INFO_NAME_REPLY}"
        local RESOURCE="${NIX_TEST_INFO_RESOURCE_REPLY}"
        local PARENT="${NIX_TEST_INFO_PARENT_REPLY}"
        
        if [[ ! "${NIX_TEST_INFO_RESOURCE_REPLY}" ]]; then
            continue
        fi

        echo 'resource' "${NAME}" "${RESOURCE}" "${PARENT:-.}"
        cat "${PTH}" | nix::record::prepend 'line' "${NAME}" "${RESOURCE}"
    done
}

nix::test::pipeline::expand::line() {
    while nix::record::expand 'line'; do
        local NAME RESOURCE OP KEY VALUE
        read -r NAME RESOURCE OP KEY VALUE <<< "${REPLY}"

        nix::test::il::line "${OP}" "${KEY}" "${VALUE}" \
            | nix::record::prepend 'explicit' "${RESOURCE}" "${NAME}"
    done
}

nix::test::pipeline::expand::resource() {
    while nix::record::expand 'resource'; do
        local NAME RESOURCE PARENT
        read -r NAME RESOURCE PARENT <<< "${REPLY}"
        
        {
            nix::test::il::activation "${RESOURCE}" "${NAME}"
            nix::test::il::user "${RESOURCE}"
            nix::test::il::assemble "${RESOURCE}"
            nix::test::il::new "${RESOURCE}"
            nix::test::il::name "${NAME}"
            nix::test::il::group "${RESOURCE}"
            nix::test::il::subscription "${RESOURCE}"

            if [[ "${PARENT}" = '.' ]]; then
                nix::test::il::location "${RESOURCE}"
            else
                nix::test::il::parent "${RESOURCE}" "${PARENT}"
            fi

            local OPTION
            for OPTION in ${NIX_AZURE_RESOURCE_POINTS_TO[${RESOURCE}]}; do
                nix::test::il::pointer \
                    "$(nix::test::option::pointer::hack "${OPTION}")" \
                    "$(nix::test::option::pointer::resource "${OPTION}")" \
                    "$(nix::test::option::pointer::type "${OPTION}")"
            done
        } | nix::record::prepend 'implicit' "${RESOURCE}" "${NAME}"
    done
}

nix::test::pipeline::override() {

    # explict options override implicit options
    local -A ENUM=( 
        [explicit]=0 
        [implicit]=1 
    )

    local SORT_FIELDS=( 
        4 # op
        3 # name
        2 # resource
        5 # key
    )

    nix::record::replace 'ENUM' \
        | sort -k1,1n \
        | nix::record::sort::stable "${SORT_FIELDS[@]}" \
        | nix::record::unique 6 "${SORT_FIELDS[@]}" \
        | nix::record::shift 6
}

nix::test::pipeline::sort() {
    local ENUMS=(
        NIX_AZURE_RESOURCE_ACTIVATION_ENUM
        ''
        NIX_TEST_OP_ENUM
   )

    local ORDERS=(
        NIX_AZURE_RESOURCE_ACTIVATION_ORDER
        ''
        NIX_TEST_OP_ORDER
    )

    local SORT=(
        '-k1,1n'    # resource; activation order
        '-k2,2'     # name; impose stable total order
        '-k3,3n'    # op
        '-k4,4'     # option
    )

    nix::record::replace "${ENUMS[@]}" \
        | sort -s "${SORT[@]}" \
        | nix::record::replace "${ORDERS[@]}"
}

nix::test::pipeline::program() {
    nix::record::project 5 3 4 5
}

nix::test::pipeline::activations() {
    local OP KEY VALUE
    while read OP KEY VALUE; do
        local USR=
        local RESOURCE=
        local PARENT_RESOURCE
        local SUBSCRIPTION=
        local NAME=
        local GROUP=
        local PARENT=
        
        while read OP KEY VALUE; do
            case "${OP}" in
            'user') USR="${VALUE}" ;;  
            'new') RESOURCE="${VALUE}" ;;  
            'subscription') SUBSCRIPTION="${VALUE}" ;;
            'group') GROUP="${VALUE}" ;;
            'name') NAME="${VALUE}" ;;
            'parent') PARENT="${VALUE}" ;;
            esac
        done < <(nix::line::take::chunk)

        [[ "${NAME}" ]] || nix::assert 'Expected name, but got nothing.'

        echo "${USR}" "${SUBSCRIPTION}" "${GROUP}" "${RESOURCE}" "${NAME}" "${PARENT}"
    done < <(
        egrep '^(activation|user|new|subscription|name|parent|group)\s' \
            | nix::line::chunk '^activation'
    )
}

nix::test::pipeline::declare() {
    declare -gA NIX_TEST_RESOURCE_TYPE_TO_ID=()
    declare -gA NIX_TEST_RESOURCE_TYPE_TO_NAME=()
    declare -gA NIX_TEST_RESOURCE_NAME_TO_ID=()
    declare -gA NIX_TEST_RESOURCE_NAME_TO_TYPE=()

    NIX_TEST_RESOURCE_TYPE_TO_ID['subnet']=$(
        nix::azure::id::subnet \
            "\${NIX_CPC_SUBSCRIPTION}" \
            "\${NIX_MY_RESOURCE_GROUP}" \
            "\${NIX_MY_VNET}" \
            "\${NIX_MY_SUBNET}"
    )
    NIX_TEST_RESOURCE_TYPE_TO_ID['fidalgo']=$(nix::azure::id "\${NIX_FID_SUBSCRIPTION}")
    NIX_TEST_RESOURCE_TYPE_TO_ID['cloud-pc']=$(nix::azure::id "\${NIX_CPC_SUBSCRIPTION}")

    local USR SUBSCRIPTION GROUP RESOURCE NAME PARENT
    while read -r USR SUBSCRIPTION GROUP RESOURCE NAME PARENT; do
        local ID=$(nix::azure::id \
            "${SUBSCRIPTION}" \
            "${GROUP}" \
            "${RESOURCE}" \
            "${NAME}" \
            "${PARENT}"
        )

        NIX_TEST_RESOURCE_TYPE_TO_ID["${RESOURCE}"]="${ID}"
        NIX_TEST_RESOURCE_TYPE_TO_NAME["${RESOURCE}"]="${NAME}"
        NIX_TEST_RESOURCE_NAME_TO_ID["${NAME}"]="${ID}"
        NIX_TEST_RESOURCE_NAME_TO_TYPE["${NAME}"]="${RESOURCE}"
    done

    readonly NIX_TEST_RESOURCE_TYPE_TO_ID
    readonly NIX_TEST_RESOURCE_TYPE_TO_NAME
    readonly NIX_TEST_RESOURCE_NAME_TO_ID
    readonly NIX_TEST_RESOURCE_NAME_TO_TYPE

    # strictly for debugging
    echo NIX_TEST_RESOURCE_TYPE_TO_ID "${#NIX_TEST_RESOURCE_TYPE_TO_ID[@]}"
    echo NIX_TEST_RESOURCE_TYPE_TO_NAME "${#NIX_TEST_RESOURCE_TYPE_TO_NAME[@]}"
    echo NIX_TEST_RESOURCE_NAME_TO_ID "${#NIX_TEST_RESOURCE_NAME_TO_ID[@]}"
    echo NIX_TEST_RESOURCE_NAME_TO_TYPE "${#NIX_TEST_RESOURCE_NAME_TO_TYPE[@]}"
}

nix::test::pipeline::reclamation() {
    local ACTIVATIONS="$1"
    shift

    cat

    local USR SUBSCRIPTION GROUP RESOURCE NAME PARENT
    while read -r USR SUBSCRIPTION GROUP RESOURCE NAME PARENT; do
        local ID="${NIX_TEST_RESOURCE_NAME_TO_ID[${NAME}]}"
        echo 'user' 'name' "${USR}"
        nix::test::il::delete "${ID}"
        echo 'disband' "${SUBSCRIPTION}" "${GROUP}"
    done < <( tac "${ACTIVATIONS}" ) \
        | tac \
        | nix::line::unique '^disband' \
        | tac
}

nix::test::pipeline::expand::assemble() {
    while nix::record::expand 'assemble'; do
        local GROUP SUBSCRIPTION LOCATION 
        read -r GROUP SUBSCRIPTION LOCATION <<< "${REPLY}"
        nix::test::il::new::group "${GROUP}" "${SUBSCRIPTION}" "${LOCATION}"
    done < <(nix::line::unique '^assemble')
}

nix::test::pipeline::expand::secure() {
    while nix::record::expand 'secure'; do
        local NAME VALUE 
        read -r NAME VALUE <<< "${REPLY}"
        nix::test::il::secure::secret "${NAME}" "${VALUE}"
    done
}

nix::test::pipeline::expand::environment() {
    while nix::record::expand 'env'; do
        local NAME VALUE
        read -r NAME VALUE <<< "${REPLY}"
        local VARIABLE=$(nix::bash::name::to_bash 'nix' "${VALUE}")
        echo 'env' "${NAME}" "\"\${${VARIABLE}}\""
    done
}

nix::test::pipeline::expand::secret() {
    while nix::record::expand 'secret'; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"
        echo 'secret' "${OPTION}" "\"\$(fd-secret-${VALUE})\""
    done
}

nix::test::pipeline::expand::secret_id() {
    while nix::record::expand 'secret-id'; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"
        echo 'pointer' "${OPTION}" 'keyvault' 'secret-id' "${VALUE}"
    done
}

nix::test::pipeline::expand::disband() {
    while nix::record::expand 'disband'; do
        local SUBSCRIPTION GROUP
        read -r SUBSCRIPTION GROUP <<< "${REPLY}"
        nix::test::il::delete $(
            nix::azure::id \
                "${SUBSCRIPTION}" \
                "${GROUP}"
        )
    done
}

nix::test::pipeline::expand::grant() {
    while nix::record::expand 'grant'; do
        local ASSIGNEE ROLE
        read -r ASSIGNEE ROLE <<< "${REPLY}"
        nix::test::il::grant "${ASSIGNEE}" "${ROLE}"
    done
}

nix::test::pipeline::expand::nominate() {
    while nix::record::expand 'nominate'; do
        local ASSIGNEE ROLE TARGET_RESOURCE
        read -r ASSIGNEE ROLE TARGET_RESOURCE <<< "${REPLY}"

        nix::test::il::nominate \
            "${ASSIGNEE}" "${ROLE}" "${TARGET_RESOURCE}"
    done
}

nix::test::pipeline::resolve::context() {
    local CONTEXT="$(mktemp)"

    while nix::record::expand 'context' "${CONTEXT}"; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"

        local RESOLUTION='?'
        case "${VALUE}" in
            'name')
                RESOLUTION="$(nix::test::context::name ${CONTEXT})"
            ;;
            'id')
                local NAME=$(nix::test::context::name ${CONTEXT})
                RESOLUTION="${NIX_TEST_RESOURCE_NAME_TO_ID[${NAME}]}"
            ;;
            'subscription')
                RESOLUTION="$(nix::test::context::subscription ${CONTEXT})"
            ;;
            *) nix::assert "Context '${VALUE}' is unexpected."
        esac

        [[ "${RESOLUTION}" ]] \
            || nix::assert "Resolution failure. '${VALUE}' failed to resolve."

        echo 'context' "${OPTION}" "${RESOLUTION}"
    done

    rm "${CONTEXT}"
}

nix::test::pipeline::resolve::persona() {
    while nix::record::expand 'persona'; do
        read -r OPTION PERSONA <<< "${REPLY}"

        if [[ "${OPTION}" == *-id ]]; then
            echo 'persona' "${OPTION}" "\$(fd-login-as-${PERSONA}; az-signed-in-user-id)"
        else
            local RESOLUTION="${NIX_PERSONA_VARIABLE[${PERSONA}]}"
            echo 'persona' "${OPTION}" "\${${RESOLUTION}}"
        fi
    done
}

nix::test::pipeline::expand::ref() {
    while nix::record::expand 'ref'; do
        local OPTION TARGET_RESOURCE
        read -r OPTION TARGET_RESOURCE <<< "${REPLY}"

        nix::test::il::pointer \
            "${OPTION}" \
            "${TARGET_RESOURCE}" \
            $(nix::test::option::pointer::type "${OPTION}")
    done
}

nix::test::pipeline::resolve::pointer() {
    local CONTEXT="$(mktemp)"

    while nix::record::expand 'pointer' "${CONTEXT}"; do
        local OPTION                                        # dev-center-id
        local TARGET_RESOURCE                               # dev-center
        local TYPE                                          # id
        local VALUE

        local SOURCE_RESOURCE=$(nix::test::context::resource "${CONTEXT}")
        local NAME=$(nix::test::context::name "${CONTEXT}")

        read -r OPTION TARGET_RESOURCE TYPE VALUE <<< "${REPLY}"

        local PREFIX="${NAME%-${SOURCE_RESOURCE}}"          # my-project > my
        local TARGET_NAME="${PREFIX}-${TARGET_RESOURCE}"    # my-dev-center

        local RESOLUTION=

        # echo "${NAME}: --${OPTION} ${TARGET_NAME} ~> ${TARGET_RESOURCE} ${TYPE}" >&2

        # attempt resolution by name; e.g my-dev-center
        if nix::bash::map::test NIX_TEST_RESOURCE_NAME_TO_ID "${TARGET_NAME}"; then
            if [[ "${TYPE}" == 'id' ]]; then
                RESOLUTION="${NIX_TEST_RESOURCE_NAME_TO_ID[${TARGET_NAME}]}"
            else
                RESOLUTION="${TARGET_NAME}"
            fi
        
        # fallback to resolution by target type; e.g. dev-center
        else
            if [[ "${TYPE}" == 'id' ]]; then
                RESOLUTION="${NIX_TEST_RESOURCE_TYPE_TO_ID[${TARGET_RESOURCE}]}"
            else
                RESOLUTION="${NIX_TEST_RESOURCE_TYPE_TO_NAME[${TARGET_RESOURCE}]}"
            fi
        fi

        if [[ "${TYPE}" == 'spid' ]]; then
            RESOLUTION="\$(az-ad-sp-id ${RESOLUTION})"

        elif [[ "${TYPE}" == 'secret-id' ]]; then
            RESOLUTION="\$(fd-secret-id ${VALUE} ${RESOLUTION} \${NIX_FID_SUBSCRIPTION})"
        fi

        echo 'pointer' "${OPTION}" "${RESOLUTION}"
    done

    rm "${CONTEXT}"
}

nix::test::pipeline::trim::group() {
    local CONTEXT="$(mktemp)"

    while nix::record::expand 'group' "${CONTEXT}"; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"

        local RESOURCE="$(nix::test::context::resource ${CONTEXT})"
        if nix::bash::map::test NIX_AZURE_RESOURCE_NO_RESOURCE_GROUP "${RESOURCE}"; then
            continue
        fi

        echo 'group' "${OPTION}" "${VALUE}"
    done

    rm "${CONTEXT}"
}

nix::test::pipeline::emit() {
    local OP KEY VALUE
    while read -r OP KEY VALUE; do
        [[ "${OP}" == 'user' ]] || nix::assert "Expected 'user', got '${OP}'."
        [[ "${KEY}" == 'name' ]] || nix::assert "Expected 'name', got '${KEY}'."
        local PERSONA="${VALUE}"

        {
            echo "set -e"
            echo "fd-login-as-${PERSONA}"

            local CTX_ID=
            local CTX_NAME=
            local CTX_SUBSCRIPTION=

            while read -r OP KEY VALUE; do
                [[ "${KEY}" == 'type' ]] || nix::assert "Expected 'type', got '${KEY}'."
                [[ "${OP}" =~ (new|set|assign|delete) ]] \
                    || nix::assert "Expected new|set|assign|delete, but got '${OP}'."

                local RESOURCE="${VALUE}"

                {
                    if [[ "${OP}" == 'new' ]]; then
                        nix::azure::cmd::resource::create "${RESOURCE}"
                    elif [[ "${OP}" == 'assign' ]]; then
                        nix::azure::cmd::role::assignment::create
                    elif [[ "${OP}" == 'set' ]]; then
                        nix::azure::cmd::resource::set "${RESOURCE}"
                    else
                        nix::azure::cmd::resource::delete "${RESOURCE}"
                    fi

                    local OPTION_LIST_PREFIX=
                    while read -r OP KEY VALUE; do
                        case "${OP}" in
                        'flag') nix::cmd::flag "${KEY}" ;;
                        'option-list') 
                            nix::cmd::option::list "${KEY}" 
                            OPTION_LIST_PREFIX="${KEY}-"
                            ;;
                        *) 
                            if [[ "${OPTION_LIST_PREFIX}" ]] \
                                && [[ "${KEY}" == ${OPTION_LIST_PREFIX}* ]]; then
                                nix::cmd::option::list::item "${KEY#${OPTION_LIST_PREFIX}}" "${VALUE}"
                                continue
                            else
                                OPTION_LIST_PREFIX=
                            fi

                            nix::cmd::option "${KEY}" "${VALUE}"
                            ;;
                        esac
                    done < <(
                        nix::line::take::chunk \
                            | nix::test::option::sort 
                    )
                } \
                    | nix::cmd::emit

            done < <(
                nix::line::take::chunk \
                    | nix::line::chunk '^(new|assign|set|delete)'
            )

        } | nix::bash::emit::subproc

    done < <(
        egrep -v ^activation \
            | nix::line::unique '^user' \
            | nix::line::chunk '^user'
    )
}
