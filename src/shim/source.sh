#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash which
cli::source cli bash function is-declared

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
    of commands and 2) declare a function which sets CLI_NAME and then calls
    cli::name with the user supplied arguments.
EOF
}

::cli::shim::source::inline() {
    local NAME="${1-}"
    [[ ${NAME} ]] || cli::assert 'Missing shim name.'

    local -n SHIM_ROOT_DIR_NAME="CLI_SHIM_ROOT_DIR_${NAME^^}"
    if [[ "${SHIM_ROOT_DIR_NAME-}" ]]; then
        return 0
    fi

    # resolve the path to the shim by searching PATH
    ::cli::bash::which::inline "$1" || return 1
    
    # source the shim
    source "${REPLY}"

    # verify shim published the path to the root of its commands
    [[ "${SHIM_ROOT_DIR_NAME-}" ]] \
        || cli::assert "Shim '$1' failed to define ${SHIM_ROOT_DIR_NAME}."

    # verify the shim published a function of the same name.
    ::cli::bash::function::is_declared::inline "${NAME}" \
        || cli::assert "Shim '$1' failed to define function ${NAME}."
}

cli::shim::source::self_test() (
    cli::temp::dir 
    local DIR="${REPLY}"
    local FOO_SHIM="${DIR}/foo"
    
    # emit a shim
    cat <<-EOF > "${FOO_SHIM}"
		#!/usr/bin/env bash-cli-shim
        declare -rg CLI_SHIM_ROOT_DIR_FOO="\${BASH_SOURCE%/*}/src"
		foo() {
		    echo ok
		}
		EOF
    chmod a+x "${FOO_SHIM}"

    ! ${CLI_COMMAND[@]} -- foo || cli::assert

    # update PATH
    PATH+=":${DIR}"

    # resolve the command
    ${CLI_COMMAND[@]} -- foo

    diff <(foo) - <<< 'ok' || cli::assert
)
