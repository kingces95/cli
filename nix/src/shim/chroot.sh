nix::chroot::test() {
    : "${NIX_CHROOT_DIR?}"
    
    [[ -d "${NIX_CHROOT_DIR}" ]]
}

# declare -g NIX_CHROOT_DIR="${HOME}/chroot"

nix::chroot::mount::list() {
    mount -l | grep chroot
}

nix::chroot::mount::test() {
    nix::chroot::mount::list \
        >/dev/null 2>&1
}

nix::chroot::mount() {
    : "${NIX_CHROOT_DIR?}"
    
    sudo mkdir -p "${NIX_CHROOT_ROOT_DIR}"
    sudo mount --bind "${NIX_HOST_ROOT_DIR}/" "${NIX_CHROOT_ROOT_DIR}/"
    sudo mount --bind "/proc/" "${NIX_CHROOT_DIR}/proc/"
    sudo mount --bind "/dev/pts" "${NIX_CHROOT_DIR}/dev/pts"
}

nix::chroot::umount() {
    : "${NIX_CHROOT_DIR?}"
    
    if ! nix::chroot::mount::test; then
        return
    fi
    
    sudo umount "${NIX_CHROOT_ROOT_DIR}/"
    sudo umount "${NIX_CHROOT_DIR}/proc/"
    sudo umount "${NIX_CHROOT_DIR}/dev/pts/"

    nix::chroot::mount::test
}

nix::chroot::initialize() {
    : "${NIX_CHROOT_DIR?}"
    
    local UNPACKED="$1"
    shift

    if ! nix::chroot::test; then
        # clone unpacked deboostrap
        (
            nix::log::subproc::begin 'nix: shim: chroot: cloning'
            sudo cp -pr "${UNPACKED}" "${NIX_CHROOT_DIR}"
        )

        # initialize chroot
        (
            nix::log::subproc::begin 'nix: shim: chroot: initializing'
            nix::chroot::initialize::locale
            nix::chroot::initialize::nix
            nix::chroot::initialize::bash_login
        )
    fi

    # computer name changes so we cannot burn this initialization into the image
    if ! nix::chroot::initialize::loopback::test; then
        nix::chroot::initialize::loopback
    fi
}

nix::chroot::remove() (
    : "${NIX_CHROOT_DIR?}"
    
    if ! nix::chroot::test; then
        nix::log::echo "nix: shim: chroot: not found at ${NIX_CHROOT_DIR}."
        return
    fi

    if nix::chroot::mount::test; then
        nix::log::echo "nix: shim: chroot: unable to remove because mounts remain."
        return
    fi

    nix::log::subproc::begin 'nix: shim: chroot: removing'
    nix::chroot::remove
)

nix::chroot::initialize::loopback::test() {
    : "${NIX_CHROOT_DIR?}"
    
    cat "${NIX_CHROOT_ETC_HOSTS}" \
        | grep "${HOSTNAME}" \
        >/dev/null 2>&1
}

nix::chroot::initialize::loopback() {
    : "${NIX_CHROOT_DIR?}"
    
    # fix: sudo: unable to resolve host codespaces-02adf7: Name or service not known
    # loopback networking chroot setup
    echo "127.0.0.1 $HOSTNAME" \
        | sudo tee -a "${NIX_CHROOT_ETC_HOSTS}" \
        >/dev/null
}

nix::chroot::initialize::locale() {
    : "${NIX_CHROOT_DIR?}"
    
    # enable en
    cat "${NIX_CHROOT_ETC_LOCALE_GEN}" \
        | sed 's/# en_US.UTF-8/en_US.UTF-8/g' \
        | sudo tee "${NIX_CHROOT_ETC_LOCALE_GEN}" \
        >/dev/null
    sudo cp "${NIX_CHROOT_DIR}/tmp/locale.gen" "${NIX_CHROOT_ETC_LOCALE_GEN}"

    (
        nix::chroot::mount
        trap nix::chroot::umount EXIT 
        sudo chroot "${NIX_CHROOT_DIR}" locale-gen
    )
}

nix::chroot::initialize::nix() (
    : "${NIX_CHROOT_DIR?}"
    
    # export NIX variables into chroot
    nix::shim::export::emit \
        | sudo tee "${NIX_CHROOT_ETC_PROFILE_NIX}" \
        >/dev/null
)

nix::chroot::initialize::bash_login() {
    : "${NIX_CHROOT_DIR?}"
    
    # default bash_login sources the loader
    cat <<-EOF | sudo tee "${NIX_CHROOT_ETC_SKEL_BASH_LOGIN}" > /dev/null
		. "\${HOME}/.profile"
		. "\${NIX_LOADER}"
		EOF
}

nix::chroot::user::test() {
    : "${NIX_CHROOT_DIR?}"
    
    local ALIAS="$1"
    shift

    sudo test -f "${NIX_CHROOT_ETC_SUDOERS_DIR}/${ALIAS}"
}

nix::chroot::user::add() {
    : "${NIX_CHROOT_DIR?}"
    
    local ALIAS="$1"
    shift

    if nix::chroot::user::test "${NIX_CHROOT_DIR}" "${ALIAS}"; then
        return
    fi

    # create user
    sudo chroot "${NIX_CHROOT_DIR}" adduser --disabled-password --gecos "" "${ALIAS}"

    # password-less sudo
    echo "${ALIAS} ALL=(root) NOPASSWD:ALL" \
        | sudo tee "${NIX_CHROOT_ETC_SUDOERS_DIR}/${ALIAS}" >/dev/null
    sudo chmod 0440 "${NIX_CHROOT_ETC_SUDOERS_DIR}/${ALIAS}"

    # sudo userdel -R "${NIX_CHROOT_DIR}" -r chrkin >/dev/null 2>&1
    # sudo useradd --create-home -R "${NIX_CHROOT_DIR}" "${ALIAS}"
}

nix::chroot::remove() {
    : "${NIX_CHROOT_DIR?}"

    if ! nix::chroot::umount; then
        return
    fi

    sudo rm -r -f "${NIX_CHROOT_DIR}"
}
