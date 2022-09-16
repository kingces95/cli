alias fd-login="nix::env::persona::switch ${NIX_PERSONA_ADMINISTRATOR}"
alias fd-login-as-administrator="nix::env::persona::switch ${NIX_PERSONA_ADMINISTRATOR}"
alias fd-login-as-developer="nix::env::persona::switch ${NIX_PERSONA_DEVELOPER}"
alias fd-login-as-vm-user="nix::env::persona::switch ${NIX_PERSONA_VM_USER}"
alias fd-login-as-vm-user-sync="nix::env::persona::switch ${NIX_PERSONA_VM_USER_SYNC}"
alias fd-login-as-network-administrator="nix::env::persona::switch ${NIX_PERSONA_NETWORK_ADMINISTRATOR}"
alias fd-login-as-me="nix::env::persona::switch ${NIX_PERSONA_ME}"

nix::env::persona::switch() {
    local PERSONA="$1"
    shift

    nix::env::tenant::switch "${NIX_FID_NAME}" "${PERSONA}"
}

nix::env::persona::create() {
    case "${NIX_ENV_PERSONA}" in
        "${NIX_PERSONA_ADMINISTRATOR}")
            nix::env::persona::administrator::create ;;
        "${NIX_PERSONA_NETWORK_ADMINISTRATOR}")
            nix::env::persona::network_administrator::create ;;
        "${NIX_PERSONA_DEVELOPER}") 
            nix::env::persona::developer::create ;;
        "${NIX_PERSONA_VM_USER}")
            nix::env::persona::vm_user::create ;;
        *) 
            echo "Uknown persona ${NIX_ENV_PERSONA}." >&2
            return 1
    esac
}

# administrator
nix::env::persona::administrator::test() (
    nix::env::persona::switch "${NIX_PERSONA_ME}"
    nix::account::admin::test
)
nix::env::persona::administrator::create() (
    nix::env::persona::switch "${NIX_PERSONA_ME}"
    nix::account::admin::create
)
nix::env::persona::administrator::delete() (
    nix::env::persona::switch "${NIX_PERSONA_ME}"
    nix::account::admin::delete
)

# developer
nix::env::persona::developer::test() (
    nix::env::persona::switch "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::test
)
nix::env::persona::developer::create() (
    nix::env::persona::switch "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::create
)
nix::env::persona::developer::delete() (
    nix::env::persona::switch "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::delete
)

# network-administrator
nix::env::persona::network_administrator::test() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ME}"
    nix::account::admin::test
)
nix::env::persona::network_administrator::create() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ME}"
    nix::account::admin::create
)
nix::env::persona::network_administrator::delete() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ME}"
    nix::account::admin::delete
)

# vm-user
nix::env::persona::vm_user::test() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::test
)
nix::env::persona::vm_user::create() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::create
)
nix::env::persona::vm_user::delete() (
    nix::env::tenant::switch "${NIX_CPC_NAME}" "${NIX_PERSONA_ADMINISTRATOR}"
    nix::account::user::delete
)
