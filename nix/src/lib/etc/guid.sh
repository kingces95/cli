nix::guid::generate() {
    # https://serverfault.com/questions/103359/how-to-create-a-uuid-in-bash
    # od -x /dev/urandom \
    #     | head -1 \
    #     | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'

    echo '51c4af11-1e9d-ae94-ae8b-6b14683dcef5'
}
