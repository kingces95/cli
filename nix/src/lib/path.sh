alias fd-path-dir="nix::path::dir"
alias fd-path-dir-name="nix::path::dir::name"
alias fd-path-file="nix::path::file"
alias fd-path-file-name="nix::path::file::name"
alias fd-path-no-extension="nix::path::no_extension"
alias fd-path-baseless="nix::path::baseless"
alias fd-path-split="nix::path::split"
alias fd-path-trim="nix::path::trim"
alias fd-path-words="nix::path::words"
alias fd-path-to-alias="nix::path::to_alias"

# make absolute
# readlink -f .

nix::path::dir() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    dirname "$1"                            # ./dri/certificate
}

nix::path::dir::name() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    local DIR="$(nix::path::dir ${PTH})"    # ./dri/certificate
    echo "${DIR##*/}"                       # certificate
}

nix::path::file() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    echo ${1##*/}                           # active-who.csl
}

nix::path::file::extension() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    local FILE="$(nix::path::file ${PTH})"  # active-who.csl
    echo "${FILE##*.}"                      # csl
}

nix::path::file::name() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    local FILE="$(nix::path::file ${PTH})"  # active-who.csl
    echo "${FILE%.*}"                       # active-who
}

nix::path::no_extension() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    echo "${PTH%.*}"                        # ./dri/certificate/active-who
}

nix::path::baseless() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    PTH="${PTH#.}"                          # /dri/certificate/active-who.csl
    echo "${PTH#/}"                         # dri/certificate/active-who.csl
}

nix::path::trim() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    PTH=$(nix::path::baseless "${PTH}")     # dri/certificate/active-who.csl
    nix::path::no_extension "${PTH}"        # dri/certificate/active-who
}

nix::path::absolute() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    local BASE="${2-$PWD}"                  # ${BASE}
    
    if [[ "${PTH}" =~ ^/ ]]; then
        echo "${PTH}"
        return
    fi

    local BASELESS=$(nix::path::baseless "${PTH}")
    echo "${BASE}/${BASELESS}"              # ${BASE}/dri/certificate/active-who.csl
}

nix::path::split() {
    local PTH="$1"                          # ./dri/certificate/active-who.csl
    nix::bash::args ${PTH//\// }            # . dri certificate active-who.csl
}

nix::path::words() {
    echo "$1" \
        | pump nix::path::trim \
        | pump nix::path::split
}

nix::path::info() {
    local PTH="$1"

    NIX_PATH_INFO_FILE_REPLY=$(nix::path::file "${PTH}")
    NIX_PATH_INFO_FILE_NAME_REPLY=$(nix::path::file::name "${PTH}")
    NIX_PATH_INFO_FILE_EXT_REPLY=$(nix::path::file::extension "${PTH}")
    NIX_PATH_INFO_DIR_NAME_REPLY=$(nix::path::dir::name "${PTH}")
    NIX_PATH_INFO_DIR_REPLY=$(nix::path::dir "${PTH}")
    NIX_PATH_INFO_DIR_PARTS_REPLY=(
        $(nix::path::words "${NIX_PATH_INFO_DIR_REPLY}" | tac)
    )
}

nix::path::to_alias() {
    nix::bash::args $(nix::path::words "$1") \
        | nix::line::join '-'
}

