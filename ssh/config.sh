function sjw() {
    iterm2_hostname="$1" iterm2_print_state_data
    ssh -t "$1" "journalctl -f -e -u ${2:-automoton.service}"
}
