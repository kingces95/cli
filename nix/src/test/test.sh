alias fd-test-build="nix::test::build"
alias fd-test-build-all="find -name '*.tst' | pump nix::test::build"

nix::test::build() {
    local PTH="$1"
    shift

    local FILE_NAME=$(nix::path::file::name "${PTH}")
    local DESTINATION="${NIX_DIR_NIX_TST_SH}/${FILE_NAME}.sh"

    nix::test::pipeline::main "${PTH}" \
        > "${DESTINATION}"
}

nix::test::cloud() {
    local TARGET="$1"
    shift

    if nix::bash::map::test NIX_PERSONA_CLOUD "${TARGET}"; then
        echo NIX_PERSONA_CLOUD["${TARGET}"]
    elif nix::bash::map::test NIX_AZURE_CPC_RESOURCE "${RESOURCE}"; then
        echo CPC
    else
        echo FID
    fi
}

nix::test::option::pointer::hack() {
    local OPTION="$1"
    shift

    if [[ "${OPTION}" == 'attached-network-name' ]]; then
        OPTION='network-connection-name'
    elif [[ "${OPTION}" == 'network-setting-id' ]]; then
        OPTION='network-connection-resource-id'
    elif [[ "${OPTION}" == 'environment-type-name' ]]; then
        OPTION='environment-type'
    fi

    echo "${OPTION}"
}

nix::test::option::pointer::resource() {
    local OPTION="$1"
    shift

    local TARGET_RESOURCE="${OPTION}"
    if [[ "${OPTION}" =~ ^([a-z0-9_-]*)-(id|name)$ ]]; then
        TARGET_RESOURCE="${BASH_REMATCH[1]}"
    fi

    echo "${TARGET_RESOURCE}"
}

nix::test::option::pointer::type() {
    local OPTION="$1"
    shift

    local TYPE='name'
    if [[ "${OPTION}" =~ -id$ ]]; then
        TYPE='id'
    fi

    echo "${TYPE}"
}

nix::test::option::sort() {
    local ENUMS=(
        NIX_TEST_OPTION_ENUM
    )

    local SORT=(
        '-k1,1n'    # identifying options
        '-k3,3'     # name
    )

    nix::record::copy 3 1 \
        | nix::record::replace "${ENUMS[@]}" \
        | sed "s/^?/$(( ${#NIX_TEST_OPTION_ENUM[@]} + 1 ))/" \
        | sort -s "${SORT[@]}" \
        | nix::record::shift 4
}

nix::test::context::subscription() {
    local CONTEXT="$1"
    shift

    tac "${CONTEXT}" \
        | nix::record::vlookup 'activation' 2
}

nix::test::context::resource() {
    local CONTEXT="$1"
    shift

    tac "${CONTEXT}" \
        | nix::record::vlookup 'activation' 3
}

nix::test::context::name() {
    local CONTEXT="$1"
    shift

    tac "${CONTEXT}" \
        | nix::record::vlookup 'activation' 4
}