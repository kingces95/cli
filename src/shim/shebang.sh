#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli path make-absolute"
    "cli path name"
    "cli shim source"
)

cli::shim::shebang::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Shim to execute a command invoked as a file.

Details
    The variable CLI_TOOL must be declared and set to the name of the shim.

    Argument \$1 is the path to the command file. The remaining positional 
    arguments are to be passed to the command.

    Construct the equivalent invocation using the shim and invoke that.
EOF
}

cli::shim::shebang() {
    local SOURCE_PATH_RELATIVE="${1-}"
    shift

    # SOURCE_PATH
    cli::path::make_absolute "${SOURCE_PATH_RELATIVE}"
    local SOURCE_PATH="${REPLY}"

    # CLI_TOOL
    [[ "${CLI_TOOL}" ]] \
        || cli::assert "Shebang failed to declare 'CLI_TOOL'." 

    # ROOT_DIR
    cli::shim::source "${CLI_TOOL}" \
        || cli::assert "Shebang failed to find shim for cli '${CLI_TOOL}'."
    local ROOT_DIR=$("${CLI_TOOL}" ---root)

    # REL_PATH
    local REL_PATH="${SOURCE_PATH##"${ROOT_DIR}/"}"
    (( ${#REL_PATH} < ${#SOURCE_PATH} )) \
        || cli::assert "Source path '${SOURCE_PATH}' is not a subpath of '${ROOT_DIR}'." 

    # COMMAND
    local IFS=/
    local -a COMMAND=( ${CLI_TOOL} ${REL_PATH} )
    IFS=${CLI_IFS}

    set "${COMMAND[@]}" "$@"

    # epilog
    unset SOURCE_PATH_RELATIVE
    unset SOURCE_PATH
    unset REL_PATH
    unset COMMAND
    unset ROOT_DIR

    # post conditions
    [[ -v CLI_TOOL ]] || cli::assert

    "$@" 
}

cli::shim::shebang::self_test() (
    cli temp dir ---source

    cli::temp::dir 
    local DIR="${REPLY}"
    local FOO_SHIM="${DIR}/foo"
    local FOO_SRC_DIR="${DIR}/src"
    local FOO_BAR="${DIR}/src/bar"

    # emit foo shim
    cat <<-EOF > "${FOO_SHIM}"
		foo() { 
            if [[ "\${1-}" == '---root' ]]; then
                echo "\${FOO_SRC_DIR}"
                return
            fi
            echo "\$@"; 
        }
		EOF
    chmod a+x "${FOO_SHIM}"

    # update PATH
    PATH="${DIR}:${PATH}"

    # discover, source, and invoke the shim with the command
    diff <(local CLI_TOOL=foo; cli::shim::shebang "${FOO_BAR}" -- a0 a1 a2) - <<< 'bar -- a0 a1 a2' \
        || cli::assert
)
