
# dotfiles: Arch logo + system info when kitty opens (logo color follows the wallpaper via matugen)
if [[ $TERM == xterm-kitty ]] && command -v fastfetch >/dev/null; then
    fastfetch
fi
