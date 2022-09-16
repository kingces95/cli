alias fd-apt-update="nix::apt::update"
alias fd-apt-update-force="nix::apt::update::force"
alias fd-apt-update-fresh="nix::apt::update::fresh::report"

nix::apt::update::fresh::package() {
    local MINUTES_SINCE_LAST_UPDATE=$(
        nix::apt::fs::package::timestamp \
            | nix::epoch::ago \
            | nix::timespan::minutes
    ) 

    (( MINUTES_SINCE_LAST_UPDATE < NIX_OS_APT_LAST_UPDATE_TIMEOUT ))
}

nix::apt::update::fresh::repository() {
    local REPOSITORY_TS=$(nix::apt::fs::repository::timestamp)
    local PACKAGE_TS=$(nix::apt::fs::package::timestamp)

    (( REPOSITORY_TS < PACKAGE_TS ))
}

nix::apt::update::fresh::pgp() {
    local PGP_TS=$(nix::apt::fs::pgp::timestamp)
    local PACKAGE_TS=$(nix::apt::fs::package::timestamp)

    (( PGP_TS < PACKAGE_TS ))
}

nix::apt::update::fresh::config() {
    [[ -f "${NIX_OS_APT_CONFIG_HASH}" ]] \
        && nix::fs::compare \
            "${NIX_OS_APT_CONFIG_HASH}" \
            <(nix::apt::config::hash)
}

nix::apt::update::fresh::lists() {
    # https://github.com/alanfranz/apt-current/blob/v1dev/apt-current
    [[ ! "$(sudo find ${NIX_OS_APT_DIR_LISTS} \
        -maxdepth 1 \
        -type f \
        -not -name lock \
        | wc -l)" -eq 0 ]]
}

nix::apt::update::fresh() {
    nix::apt::update::fresh::package \
        && nix::apt::update::fresh::repository \
        && nix::apt::update::fresh::pgp \
        && nix::apt::update::fresh::config \
        && nix::apt::update::fresh::lists
}

nix::apt::update::fresh::report() {
    echo "package" "$(nix::apt::update::fresh::package; echo $?)"
    echo "repository" "$(nix::apt::update::fresh::repository; echo $?)"
    echo "pgp" "$(nix::apt::update::fresh::pgp; echo $?)"
    echo "config" "$(nix::apt::update::fresh::config; echo $?)"
    echo "lists" "$(nix::apt::update::fresh::lists; echo $?)"
}

nix::apt::update() {
    if nix::apt::update::fresh; then
        return
    fi

    nix::apt::update::force
}

nix::apt::update::force() (
    nix::log::subproc::begin "nix: apt: updating"
    nix::apt::update::fresh::report 
    nix::apt::sudo::update 

    nix::sudo touch "${NIX_OS_APT_PACKAGE_TIMESTAMP}"
    nix::apt::config::hash \
        | nix::sudo::write "${NIX_OS_APT_CONFIG_HASH}"
)