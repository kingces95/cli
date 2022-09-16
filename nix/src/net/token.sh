alias fd-token-parse="nix::token::parse"

nix::token::parse() {
    # https://gist.github.com/dlenski/63509482df8ec0090e1439fc70ae2c8e

    local TOKEN
    IFS=. read -r -a TOKEN

    # Convert from URL-safe b64 to "standard" b64, and fix padding
    for i in $(seq 0 2); do
        TOKEN[$i]=$(tr '_-' '/+' <<< "${TOKEN[$i]}")
        case $(( ${#TOKEN[$i]} % 4 )) in
            1) TOKEN[$i]+="===" ;;
            2) TOKEN[$i]+="==" ;;
            3) TOKEN[$i]+="=" ;;
        esac
    done

    echo "Header:"
    echo "${TOKEN[0]}" | base64 -d | jq

    echo "Claims:"
    echo "${TOKEN[1]}" | base64 -d | jq

    echo "Signature:"
    echo "${TOKEN[2]}" | base64 -d | hexdump -v -e '30/1 "%02X" 1/30 "\n"'
}
