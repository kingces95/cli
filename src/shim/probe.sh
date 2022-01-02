#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli shim which

cli::shim::probe::help() {
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

::cli::shim::probe::inline() {
    ::cli::shim::which::inline "${1-}"
    shift

    MAPFILE=()

    local IFS=/
    REPLY="${REPLY}/$*"
    MAPFILE+=( "${REPLY}" )

    # probe for .sh
    if [[ ! -f "${REPLY}" ]]; then
        REPLY+='.sh'
        MAPFILE+=( "${REPLY}" )
    fi

    [[ -f "${REPLY}" ]]
}

cli::shim::probe::self_test() (
    diff <(echo $0) <(${CLI_COMMAND[@]} ---reply cli shim probe) || cli::assert

    cli::temp::dir 
    local DIR="${REPLY}"

    local FOO_SHIM="${DIR}/foo"
    local FOO_SRC_DIR="${DIR}/src"
    local FOO_BAR="${DIR}/src/bar"
    
    # emit foo shim
    cat <<-EOF > "${FOO_SHIM}"
		#!/usr/bin/env bash-cli-shim
        declare -rg CLI_SHIM_ROOT_DIR_FOO="\${FOO_SRC_DIR}"
		foo() { cli::assert; }
		EOF
    chmod a+x "${FOO_SHIM}"

    # emit bar
    mkdir "${FOO_SRC_DIR}"
    echo > "${FOO_BAR}"

    ! ${CLI_COMMAND[@]} -- foo bar || cli::assert

    # update PATH
    PATH+=":${DIR}"

    ${CLI_COMMAND[@]} -- foo bar || cli::assert ${REPLY}

    # which foo
    diff <(${CLI_COMMAND[@]} ---reply foo bar) - <<< "${FOO_BAR}" \
        || cli::assert "$(${CLI_COMMAND[@]} ---reply foo bar) != ${FOO_BAR}"
)
