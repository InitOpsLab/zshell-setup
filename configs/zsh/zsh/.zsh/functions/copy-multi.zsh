# ~/.zsh/functions/copy-multi.zsh

# Copy to Multiple Locations
copy_to_multiple() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: copy_to_multiple <source> <destination1> <destination2> ..."
        return 1
    fi

    src="$1"
    shift

    for dest in "$@"; do
        cp -r "$src" "$dest" && echo "Copied to $dest" || echo "Failed to copy to $dest"
    done
}

