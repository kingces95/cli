alias fd-tool-nuget-rows="nix::tool::nuget::rows"
alias fd-tool-nuget-list="nix::tool::nuget::list"
alias fd-tool-nuget-xml="nix::tool::nuget::xml"
alias fd-tool-nuget-dir="nix::tool::nuget::dir"
alias fd-tool-nuget-package="nix::tool::nuget::package"
alias fd-tool-nuget-version="nix::tool::nuget::version"
alias fd-tool-nuget-framework="nix::tool::nuget::framework"
alias fd-tool-nuget-install-test="nix::tool::nuget::install::test"
alias fd-tool-nuget-install="nix::tool::nuget::install"
alias fd-tool-nuget-uninstall="nix::tool::nuget::uninstall"
alias fd-tool-nuget-scorch="nix::tool::nuget::scorch"

nix::tool::nuget::rows() {
    nix::tool::cat \
        | nix::table::filter::match 'nuget' 2
}

nix::tool::nuget::list() {
    nix::tool::nuget::rows \
        | nix::table::project 1
}

nix::tool::nuget::lookup() {
    local NAME="$1"
    shift

    nix::tool::nuget::rows \
        | nix::table::vlookup "${NAME}" "$@"
}

nix::tool::nuget::test() {
    local NAME="$1"
    shift

    nix::tool::nuget::list \
        | nix::table::contains "${NAME}"
}

nix::tool::nuget::package() {
    local NAME="$1"
    shift

    nix::tool::nuget::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_PACKAGE}"
}

nix::tool::nuget::version() {
    local NAME="$1"
    shift

    nix::tool::nuget::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_VERSION}"
}

nix::tool::nuget::framework() {
    local NAME="$1"
    shift

    nix::tool::nuget::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_FRAMEWORK}"
}

nix::tool::nuget::scorch() {
    nix::fs::dir::remove "${NIX_TOOL_NUGET_DIR}"
}

nix::tool::nuget::dir() {
    local NAME="$1"
    shift

    nix::tool::nuget::test "${NAME}" \
        || nix::assert "No nuget tool '${NAME}' found."

    echo "${NIX_TOOL_NUGET_DIR}/${NAME}"
}

nix::tool::nuget::xml() {
    local NAME="$1"
    shift

    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"
    local VERSION="$(nix::tool::nuget::version "${NAME}")"
    local FRAMEWORK="$(nix::tool::nuget::framework "${NAME}")"

    cat <<-EOF
		<?xml version="1.0" encoding="utf-8"?>
		<packages>
		  <package 
		    id="${PACKAGE}" 
		    version="${VERSION}" 
		    targetFramework="${FRAMEWORK}" 
		  />
		</packages>
	EOF
}

nix::tool::nuget::install::test() {
    local NAME="$1"
    shift

    local DIR="$(nix::tool::nuget::dir "${NAME}")"

    [[ -d "${DIR}" ]]
}

nix::tool::nuget::install() (
    local NAME="$1"
    shift

    if nix::tool::nuget::install::test "${NAME}"; then
        return
    fi

    local DIR="$(nix::tool::nuget::dir "${NAME}")"
    mkdir -p "${DIR}"

    local CONFIG="${DIR}/packages.config"
    nix::tool::nuget::xml "${NAME}" > "${CONFIG}"
    
    cd "${DIR}"

    nix::tool::install 'nuget'

    (
        local PACKAGE="$(nix::tool::nuget::package "${NAME}")"
        nix::log::subproc::begin "nix: nuget: installing ${PACKAGE}"
        nuget install
    )
)

nix::tool::nuget::uninstall() {
    local NAME="$1"
    shift

    if ! nix::tool::nuget::install::test "${NAME}"; then
        return
    fi

    local DIR="$(nix::tool::nuget::dir "${NAME}")"
    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"

    nix::log::begin "nix: nuget: uninstalling ${PACKAGE}"
    nix::fs::dir::remove "${DIR}"
    nix::log::end
}
