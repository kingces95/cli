nix::epoch::timestamp() {
    date +%s%3N
}

nix::epoch::ago() {
    local AGE=$(nix::epoch::timestamp)
    
    read
    echo $(( AGE - REPLY ))
}
