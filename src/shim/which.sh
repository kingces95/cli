#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli shim source"
)

cli::shim::which::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Resolve a cli command to a path.

Arguments
    Argument \$1 is the name of the cli. If the shim for \$1 is not found, 
    the call fails, otherwise succeeds.

    Arguments \$2 and greater are the groups leading to the command. They are
    joined together with forward shashes and that string is joined to the root 
    directory of the commands for the cli again with a forward slash and that 
    string is then assigned to REPLY.
EOF
}

cli::shim::which() {
    local NAME="$1"
    shift

    cli::shim::source "${NAME}" || return 1

    local -n SHIM_ROOT_DIR_REF="CLI_SHIM_ROOT_DIR_${NAME^^}"
    [[ "${SHIM_ROOT_DIR_REF-}" ]] || cli::assert

    REPLY="${SHIM_ROOT_DIR_REF}"
}

cli::shim::which::self_test() (
    cli::temp::dir 
    local DIR="${REPLY}"

    local FOO_SHIM="${DIR}/foo"
    local FOO_SRC_DIR="${DIR}/src"
    
    # emit foo shim
    cat <<-EOF > "${FOO_SHIM}"
		#!/usr/bin/env bash-cli-shim
        declare -rg CLI_SHIM_ROOT_DIR_FOO="\${FOO_SRC_DIR}"
		foo() { cli::assert; }
		EOF

    chmod a+x "${FOO_SHIM}"

    ! ${CLI_COMMAND[@]} -- foo || cli::assert

    # update PATH
    PATH+=":${DIR}"

    ${CLI_COMMAND[@]} -- foo || cli::assert ${REPLY}
)
