#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli temp fifo
cli::source cli temp remove

cli::bash::group::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Group records into pipes.

Description
    Argument $1 is the number of fields of each record to use as the key.
    The fields are one based. Default is one.

    Return a record for each unique key discovered in the records read
    from stdin. The retuned records contain as many fields as are present
    in the key plus one for a file descriptor which contains the group 
    members and be drained before the next group record is produced. 
    The file descriptor contians only the fields that follow the key of 
    the grouped record read from stdin.
EOF
    cat << EOF
Examples
EOF
}

cli::bash::group::inline() {
    local ARG_KEYS=${1-1}

    local current_key=
    local -a groups=()
    local -a keys=()
    local key=

    # while read -a REPLY; do
    while read -a reply; do
        (( ${#reply[@]} > 0 )) || cli::assert "Records must contain a key."

        key="${reply[@]:0:${ARG_KEYS}}"

        if [[ ! "${key}" == "${current_key}" ]]; then

            # activate ith group
            local group=GROUP_${#keys[@]}
            local -a "${group}=()"
            local -n group_ref=${group}

            # push new key
            keys+=( "${key}" )

            # update current
            current_key="${key}"
        fi

        # record group member
        group_ref+=( "${reply[*]:${ARG_KEYS}}" )
    done

    # publish groups
    for (( i=0; i<${#keys[@]}; i++ )); do

        # activate pipe
        cli::temp::fifo::inline
        set -- "${REPLY}"

        # publish group
        echo "${keys[$i]}" "$1"

        # publish members
        local -n group_ref=GROUP_${i}
        printf '%s\n' "${group_ref[@]}" > "$1"
    
        # delete pipe
        cli::temp::remove::inline "$1"
    done
}

cli::bash::group::self_test() {
    {
        echo a 0 x
        echo a 1 y
        echo b 2 z
    } | ${CLI_COMMAND[@]} -- | {
        while read -a reply; do
            echo group ${reply}
            cat ${reply[1]}
        done
    } | diff <( cat <<-EOF
			group a
			0 x
			1 y
			group b
			2 z
			EOF
    ) - || cli::assert
        
    {
        echo a 0 x
        echo a 0 y
        echo a 1 z
    } | ${CLI_COMMAND[@]} -- 2 | {
        while read -a reply; do
            echo group ${reply[@]:0:2}
            cat ${reply[2]}
        done
    } | diff <( cat <<-EOF
			group a 0
			x
			y
			group a 1
			z
			EOF
    ) - || cli::assert
}
