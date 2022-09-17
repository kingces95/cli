CLI_IMPORT=(
    "cli bash function is-declared"
    "cli bash which"
)

cli::shim::source::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Source the cli shim.

Description
    Argument $1 is the name of the shim (e.g. 'cli').

    Searches PATH for $1 and then sources the file or fails
    if the shim is not found on PATH.

    When sourced the shim must 1) declare CLI_SHIM_ROOT_DIR_XXX where XXX is 
    the name of the cli and the value of the variable is the root directory
    of commands and 2) declare a function which sets CLI_TOOL and then calls
    cli::name with the user supplied arguments.
EOF
}

cli::shim::source() {
    local NAME="${1-}"
    shift

    [[ ${NAME} ]] || cli::assert 'Missing shim name.'

    if declare -F "${NAME}" >/dev/null; then
        return
    fi

    # resolve the path to the shim by searching PATH
    cli::bash::which "${NAME}" \
        || cli::assert "Failed to find shim '${NAME}' on the path."

    # source the shim
    source "${REPLY}"

    # verify the shim published a function of the same name.
    cli::bash::function::is_declared "${NAME}" \
        || cli::assert "Shim '${NAME}' failed to define function ${NAME}."
}

cli::shim::source::self_test() (
    cli temp dir ---source

    cli::temp::dir 
    local DIR="${REPLY}"
    local FOO_SHIM="${DIR}/foo"
    
    # emit a shim
    cat <<-EOF > "${FOO_SHIM}"
		#!/usr/bin/env bash-cli-shim
		foo() {
            if [[ "\${1-}" == '---root' ]]; then
                echo "\${BASH_SOURCE%/*}/src"
                return
            fi
		    echo ok
		}
		EOF
    chmod a+x "${FOO_SHIM}"

    # update PATH
    PATH+=":${DIR}"

    # source foo shim
    ${CLI_COMMAND[@]} -- foo

    diff <(foo) - <<< 'ok' || cli::assert
)
