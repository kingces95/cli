nix::shim::load() {
    local EXIT_REMAIN=101
    (
        readonly NIX_HOST_ROOT_DIR="$(cd "$(dirname ${BASH_SOURCE})/.."; pwd)"

        declare -xr NIX_EXIT_REMAIN="${EXIT_REMAIN}"
        declare -xr NIX_ROOT_DIR="/workspaces"
        declare -xr NIX_REPO_DIR="${NIX_HOST_ROOT_DIR}/fidalgo-dev"
        declare -xr NIX_DIR="${NIX_REPO_DIR}/nix"
        declare -xr NIX_LOADER="${NIX_DIR}/loader.sh"
        declare -xr NIX_DIR_NIX_USR="${NIX_DIR}/usr"
        declare -xr NIX_DIR_NIX_SRC="${NIX_DIR}/src"

        readonly NIX_CHROOT_DIR="${HOME}/chroot"    
        readonly NIX_CHROOT_ROOT_DIR="${NIX_CHROOT_DIR}${NIX_ROOT_DIR}/"
        readonly NIX_CHROOT_ETC_HOSTS="${NIX_CHROOT_DIR}/etc/hosts"
        readonly NIX_CHROOT_ETC_LOCALE_GEN="${NIX_CHROOT_DIR}/etc/locale.gen"
        readonly NIX_CHROOT_ETC_PROFILE_NIX="${NIX_CHROOT_DIR}/etc/profile.d/nix.sh"
        readonly NIX_CHROOT_ETC_SKEL_BASH_LOGIN="${NIX_CHROOT_DIR}/etc/skel/.bash_login"
        readonly NIX_CHROOT_ETC_SUDOERS_DIR="${NIX_CHROOT_DIR}/etc/sudoers.d"

        # source *.sh files
        . "${NIX_DIR}/env.sh"
        while read; do source "${REPLY}"; done \
            < <(find "${NIX_DIR_NIX_SRC}" -type f -name "*.sh")

        nix::shim::main "$@"
    )

    local EXIT_CODE=$?
    if (( EXIT_CODE == EXIT_REMAIN )); then
        return
    fi

    exit "${EXIT_CODE}"
}

nix::shim::load "$@"
