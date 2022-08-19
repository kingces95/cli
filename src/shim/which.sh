#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli shim which"
)

cli::shim::which::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Resolve a cli command to a path.

Arguments
    Argument \$1 is the name of the cli. If the shim for \$1 is not found, 
    the call asserts.

    Arguments \$2 and greater are the groups leading to the command. They are
    joined together with forward shashes and that string is joined to the root 
    directory of the commands for the cli again with a forward slash. That path
    is probed and if nothing found than a '.sh' is appended. The path found is
    assigned to REPLY. The paths probed and listed in MAPFILE. The function fails
    if no file is found, otherwise succeeds. 
EOF
}

cli::shim::which() {
    local SHIM="${1-}"
    shift

    cli::shim::source "${SHIM}" || return 1

    REPLY=$( ${SHIM} ---root )
    
    [[ -d "${REPLY}" ]] \
        || cli::assert "Shim '${SHIM} ---root' returned '${REPLY}' which is not a directory."

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

cli::shim::which::self_test() (
    cli temp dir ---source
    
    diff <(echo $0) <(${CLI_COMMAND[@]} ---reply cli shim which) || cli::assert

    cli::temp::dir 
    local DIR="${REPLY}"

    local FOO_SHIM="${DIR}/foo"
    local FOO_SRC_DIR="${DIR}/src"
    local FOO_BAR="${DIR}/src/bar"
    
    # emit foo shim
    cat <<-EOF > "${FOO_SHIM}"
		#!/usr/bin/env bash-cli-shim
		foo() { 
            if [[ "\${1-}" == '---root' ]]; then
                echo "\${FOO_SRC_DIR}"
                return
            fi
            cli::assert
        }
		EOF
    chmod a+x "${FOO_SHIM}"

    # emit bar
    mkdir "${FOO_SRC_DIR}"
    echo > "${FOO_BAR}"

    # ! ${CLI_COMMAND[@]} -- foo bar || cli::assert

    # update PATH
    PATH+=":${DIR}"

    ${CLI_COMMAND[@]} -- foo bar || cli::assert ${REPLY}

    # which foo
    diff <(${CLI_COMMAND[@]} ---reply foo bar) - <<< "${FOO_BAR}" \
        || cli::assert "$(${CLI_COMMAND[@]} ---reply foo bar) != ${FOO_BAR}"
)
