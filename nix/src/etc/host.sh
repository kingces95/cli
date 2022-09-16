alias host-ip="nix::host::ip"

nix::host::ip() {
    cat /etc/resolv.conf \
        | grep nameserver \
        | awk ' { print $2 }'
}
