#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Assign REPLY with a bash literal of the first argument as would be returned by 
    'display -p' for a map key.
EOF
}

::cli::bash::emit::indent::inline() {
    local PREFIX="${1-}"
    local FIRST=true
    local EMIT_TAB="    "
    local REGEX='<< ([A-Z]+)'
    local EOF=

    while read -r; do

        if ${FIRST} && [[ "${PREFIX}" ]]; then
            echo -n "${PREFIX}"
        fi
        FIRST=false

        # start heredoc
        if [[ "${REPLY}" =~ ${REGEX} ]]; then
            echo "${EMIT_TAB}${REPLY}"
            EOF=${BASH_REMATCH[1]}

            # in heredoc
            while read -r; do
                echo "${REPLY}"
            
                # end heredoc
                if [[ "${REPLY}" == "${EOF}" ]]; then
                    break
                fi
            done

            continue
        fi

        echo "${EMIT_TAB}${REPLY}"
    done
}

cli::bash::emit::indent::self_test() {
    local TAB='    '
    diff <( ${CLI_COMMAND[@]} -- <<< "." ) - <<< $"    ."
    diff <( ${CLI_COMMAND[@]} -- <<< $'.\n    .' ) - <<< $'    .\n        .'
}
