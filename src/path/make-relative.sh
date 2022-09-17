
cli::path::make_relative::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Given \$1 and \$2 are absolute paths beginning with /
    returns relative path to \$2 from \$1.
EOF
    cat << EOF

Examples
    Make relative "/A/B/C" "/A" -->  "../.."
        ${CLI_COMMAND[@]} -- "/A/B/C" "/A"

Credit
    https://stackoverflow.com/questions/2564634
EOF
}

cli::path::make_relative() {
    local source=$1
    local target=$2

    local common_part=${source} # for now
    local result="" # for now

    while [[ "${target#${common_part}}" == "${target}" ]]; do
        # no match, means that candidate common part is not correct
        # go up one level (reduce common part)
        common_part="$(dirname "${common_part}")"
        # and record that we went back, with correct / handling
        if [[ -z "${result}" ]]; then
            result=".."
        else
            result="../${result}"
        fi
    done

    if [[ "${common_part}" == "/" ]]; then
        # special case for root (no common path)
        result="${result}/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    forward_part="${target#${common_part}}"

    # and now stick all parts together
    if [[ "${result}" ]] && [[ "${forward_part}" ]]; then
        result="${result}${forward_part}"
    elif [[ "${forward_part}" ]]; then
        # extra slash removal
        result="${forward_part:1}"
    fi

    echo "${result}"
}

cli::path::make_relative::self_test() {
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A") == "../.." ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B") == ".." ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B/C") == "" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B/C/D") == "D" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B/C/D/E") == "D/E" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B/D") == "../D" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/B/D/E") == "../D/E" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/D") == "../../D" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/A/D/E") == "../../D/E" ]] || cli::assert
    [[ $(${CLI_COMMAND[@]} -- "/A/B/C" "/D/E/F") == "../../../D/E/F" ]] || cli::assert
}
