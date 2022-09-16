alias fd-kusto="NIX_KUSTO_PIPELINE_SKIP=1 nix::fidalgo::kusto"
alias fd-kusto-with-headers="nix::fidalgo::kusto"
alias fd-kusto-raw="nix::fidalgo::kusto::raw"
alias fd-kusto-ad-hoc="nix::fidalgo::kusto::ad_hoc"
alias fd-kusto-ad-hoc-raw="nix::fidalgo::kusto::ad_hoc::raw"

nix::fidalgo::kusto::install() {
    nix::tool::install 'kusto'
}

nix::fidalgo::kusto() {
    nix::fidalgo::kusto::install
    nix::azure::tenant::public::eval \
        nix::kusto::execute "$@"
}

nix::fidalgo::kusto::raw() {
    nix::fidalgo::kusto::install
    nix::azure::tenant::public::eval \
        nix::kusto::execute::raw "$@"
}

nix::fidalgo::kusto::ad_hoc() {
    echo "$@" \
    | nix::fidalgo::kusto    
}

nix::fidalgo::kusto::ad_hoc::raw() {
    echo "$@" \
    | nix::fidalgo::kusto::raw    
}
