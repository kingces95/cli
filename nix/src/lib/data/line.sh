alias fd-line-fit="nix::line::fit"
alias fd-line-exe="nix::line::execute"
alias fd-line-skip="nix::line::skip"
alias fd-line-except="nix::line::except"
alias fd-line-chunk="nix::line::chunk"

nix::line::skip() {
    tail -n +$(( ${1-1} + 1 ))
}

nix::line::prepend() {
    local VALUE="$1"

    sed "s/^/${VALUE}/g"
}

nix::line::first() {
    local SEARCH_TERM="$1"
    shift

    grep -m 1 "${SEARCH_TERM}"
}

nix::line::chunk() {
    local SEARCH_TERM="$1"
    shift

    nix::line::take::one

    while read -r; do
        if [[ "${REPLY}" =~ ${SEARCH_TERM} ]]; then
            echo
        fi
        echo "${REPLY}"
    done
}

nix::line::take::one() {
    read -r
    echo "${REPLY}"
}

nix::line::take::chunk() {
    while read -r; do
        if [[ ! "${REPLY}" ]]; then
            return
        fi
        echo "${REPLY}"
    done
}

nix::line::join() (
    IFS="${1- }"
    shift

    mapfile -t
    echo "${MAPFILE[*]}"
)

nix::line::fit() {
    while read -r; do
        echo "${REPLY:0:$COLUMNS}"
    done
}

nix::line::execute() {
    mapfile -t
    "${MAPFILE[@]}"
}

nix::line::except() {
    comm - "$1" -23
}

nix::line::max() {
    local MAX=0
    while read -r; do
        if (( REPLY > MAX )); then
            MAX="${REPLY}"
        fi
    done
    echo "${MAX}"
}

nix::line::min() {
    local MIN=0
    while read -r; do
        if (( REPLY < MAX )); then
            MIN="${REPLY}"
        fi
    done
    echo "${MIN}"
}

nix::line::contains() {
    nix::record::contains 1 "$@"
}

nix::line::unique() {
    local REGEX="${1-*}"
    shift

    local LAST_REPLY
    while read -r; do
        if [[ "${REPLY}" =~ ${REGEX} ]]; then
            if [[ "${REPLY}" == "${LAST_REPLY}" ]]; then
                continue
            fi

            LAST_REPLY="${REPLY}"
        fi

        echo "${REPLY}"
    done
}

nix::line::trim::start() {
    while read -r; do
        if [[ ! "${REPLY}" ]]; then
            continue
        fi
    done
    echo "${REPLY}"
}

nix::line::trim::end() {
    local EMPTY_LINE=false
    while read -r; do
        if [[ ! "${REPLY}" ]]; then
            EMPTY_LINE=true
            continue
        fi

        if "${EMPTY_LINE}"; then
            echo
            EMPTY_LINE=false
        fi

        echo "${REPLY}"
    done
}