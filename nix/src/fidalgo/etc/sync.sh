nix::sync::retry() {
    local -i TIMER="$1"
    shift

    local -i DELAY="$1"
    shift

    local MESSAGE="$*"
    shift

    local STATUS
    local CODE

    mapfile -t COMMAND

    nix::log::begin "${MESSAGE}"
    tput sc
    for (( TIMER; TIMER>0; TIMER-- )); do
    
        "${COMMAND[@]}" 1>/dev/null 2>/dev/null
        CODE="$?"

        # clear
        tput rc
        nix::log::printf "%-${#STATUS}s"

        # paint
        tput rc
        STATUS="(exit=${CODE}, timer=${TIMER})"
        nix::log::printf '%s ' "${STATUS}"

        if (( CODE == 0 )); then
            break
        fi

        # sleep
        sleep "${DELAY}"
    done
    nix::log::end
}
