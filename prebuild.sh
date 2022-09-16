ROOT=$(dirname "${BASH_SOURCE}")

. "${ROOT}/shim.sh" nix::tool::install::all
. "${ROOT}/nix/src/shim/debootstrap.sh"

nix::debootstrap::clean focal
