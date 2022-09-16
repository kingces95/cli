alias links="find -type l -printf '%p -> %l\n' | a3f"
alias fd-fs-files=nix::fs::files
alias fd-fs-dirs=nix::fs::dirs
alias fd-fs-cat=nix::fs::cat

nix::fs::dirs() (
    local PTH="${1:-$PWD}"
    cd "${PTH}"
    find -L ~+ -type d | sort
)

nix::fs::files() (
    local PTH="${1:-$PWD}"
    cd "${PTH}"
    find -L ~+ -type f | sort
)

nix::fs::cat() {
    local FIRST=true

    while read; do
        if ! "${FIRST}"; then
            echo
        fi
        FIRST=false
        
        echo "${REPLY}"
        cat "${REPLY}" | nix::bash::emit::indent
    done
}

nix::fs::copy() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    local DIR=$(dirname ${DESTINATION})
    mkdir -p ${DIR}

    cp "${SOURCE}" "${DESTINATION}"
}

nix::fs::file::remove() {
    local PTH="$1"

    if [[ ! -f "${PTH}" ]]; then
        return
    fi

    rm "${PTH}"
}

nix::fs::dir::remove() {
    local DIR="$1"

    if [[ ! -d "${DIR}" ]]; then
        return
    fi

    rm -f -r "${DIR}"
}

nix::fs::timestamp() {
    local PTH="$1"
    shift

    stat -c%Y000 "${PTH}"
}

nix::fs::compare() {
    local LEFT="$1"
    shift

    local RIGHT="$1"
    shift

    cmp --silent "${LEFT}" "${RIGHT}"
}

nix::fs::walk() {
    local EXT="$1"
    shift

    if (( $# == 0)); then
        return
    fi

    local NODE=()

    while read -r; do
        local PTH="${REPLY}"

        local PATH_ABSOLUTE=$(nix::path::absolute "${PTH}")
        local PATH_EXT="$(nix::path::file::extension "${PTH}")"

        if [[ ! "${EXT}" == "${PATH_EXT}" ]]; then
            echo "${PATH_ABSOLUTE}"
            continue
        fi

        NODE+=( "${PATH_ABSOLUTE}" )
    done < <(
        nix::bash::args "$@" \
            | pump cat
    )

    nix::fs::walk "${EXT}" "${NODE[@]}"
}

nix::fs::dir::create() {
    local DIR="$1"
    shift

    mkdir -p "${DIR}"
}

nix::fs::touch() {
    local PTH="$1"
    shift

    nix::fs::dir::create "$(nix::path::dir "$PTH")"
    
    touch "${PTH}"
}

nix::fs::insert() {
    local PTH="$1"
    shift

    echo "$*" >> "${PTH}"
    sort -o "${PTH}" "${PTH}"
}
