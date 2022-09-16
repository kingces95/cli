nix::timespan::seconds() {
    read
    echo $(( REPLY / 1000 ))
}

nix::timespan::minutes() {
    read < <(nix::timespan::seconds)
    echo $(( REPLY / 60 ))
}

nix::timespan::hours() {
    read < <(nix::timespan::minutes)
    echo $(( REPLY / 60 ))
}
