#!/usr/bin/env bash
# h7p5 dotfiles installer: revo-shell (macOS shell) + my patches + my own configs.
#
#   ./install.sh                 install configs (backs up what it replaces)
#   ./install.sh --build-extras  also build the hyprliquid plugin and System Settings app
#
# It never uses sudo. Missing packages are listed so you can install them yourself.
set -euo pipefail

REVO_URL="${REVO_URL:-https://github.com/vzbc/revo-shell}"
REVO_COMMIT="6685a9fcf548d6ff4455a8e0015d36f22e73adbb"
LIQUID_URL="https://github.com/zaregototsukai/hyprliquid"
LIQUID_COMMIT="16abd07"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/h7p5-dotfiles"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BUILD_EXTRAS=0
[[ "${1:-}" == "--build-extras" ]] && BUILD_EXTRAS=1

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

# 1. dependencies ------------------------------------------------------------
missing=()
for c in Hyprland kitty fastfetch matugen git patch python3; do command -v "$c" >/dev/null || missing+=("$c"); done
command -v qs >/dev/null || command -v quickshell >/dev/null || missing+=("quickshell (AUR: quickshell-git)")
command -v awww >/dev/null || missing+=("awww")
if ((${#missing[@]})); then
    warn "Missing: ${missing[*]}"
    warn "Install them first (e.g. sudo pacman -S --needed hyprland kitty fastfetch matugen git patch python + quickshell-git/awww from the AUR)."
    exit 1
fi

# 2. revo-shell at a pinned commit, with my patches ------------------------------
say "Fetching revo-shell ($REVO_COMMIT)"
mkdir -p "$CACHE"
if [[ ! -d "$CACHE/revo-shell/.git" ]]; then
    git clone --filter=blob:none "$REVO_URL" "$CACHE/revo-shell}"
fi
git -C "$CACHE/revo-shell" fetch -q origin "$REVO_COMMIT" || true
git -C "$CACHE/revo-shell" checkout -q -f "$REVO_COMMIT"
git -C "$CACHE/revo-shell" clean -qfd

say "Applying patches"
for p in "$HERE"/patches/*.patch; do
    patch -d "$CACHE/revo-shell" -p1 --forward --no-backup-if-mismatch < "$p"
done

say "Pointing revo paths at $HOME"
grep -rlI '/home/revo' "$CACHE/revo-shell/hypr" "$CACHE/revo-shell/kitty" "$CACHE/revo-shell/quickshell/macos" "$CACHE/revo-shell/quickshell/eqsh" 2>/dev/null \
    | xargs -r sed -i "s#/home/revo#$HOME#g"

# 3. back up and install -----------------------------------------------------
read -rp "Replace ~/.config/{hypr,kitty,fastfetch,matugen,quickshell/macos,quickshell/eqsh}? A backup goes to $BACKUP [y/N] " ok
[[ "$ok" =~ ^[Yy]$ ]] || { warn "Stopped, nothing changed."; exit 0; }

mkdir -p "$BACKUP/quickshell"
for d in hypr kitty fastfetch matugen; do [[ -e "$CFG/$d" ]] && mv "$CFG/$d" "$BACKUP/"; done
for d in macos eqsh; do [[ -e "$CFG/quickshell/$d" ]] && mv "$CFG/quickshell/$d" "$BACKUP/quickshell/"; done
say "Old configs saved in $BACKUP"

mkdir -p "$CFG/quickshell"
cp -a "$CACHE/revo-shell/hypr"  "$CFG/hypr"
cp -a "$CACHE/revo-shell/kitty" "$CFG/kitty"
cp -a "$CACHE/revo-shell/quickshell/macos" "$CACHE/revo-shell/quickshell/eqsh" "$CFG/quickshell/"
cp -a "$HERE/config/hypr/achraf.lua" "$CFG/hypr/"
cp -a "$HERE/config/fastfetch" "$HERE/config/matugen" "$CFG/"
echo macos > "$CFG/hypr/.revo_default_shell"

if ! grep -q 'dotfiles: Arch logo' "$HOME/.bashrc" 2>/dev/null; then
    cat "$HERE/home/bashrc-snippet.sh" >> "$HOME/.bashrc"
fi

mkdir -p "$HOME/Pictures/Wallpapers"
[[ -e "$HOME/Pictures/Wallpapers/revo" ]] || ln -s "$CACHE/revo-shell/wallpapers" "$HOME/Pictures/Wallpapers/revo"
[[ -e "$CFG/wallpapers" ]] || ln -s "$HOME/Pictures/Wallpapers" "$CFG/wallpapers"

# 4. optional builds ----------------------------------------------------------
if ((BUILD_EXTRAS)); then
    say "Building hyprliquid ($LIQUID_COMMIT)"
    [[ -d "$CACHE/hyprliquid/.git" ]] || git clone "$LIQUID_URL" "$CACHE/hyprliquid"
    git -C "$CACHE/hyprliquid" checkout -q "$LIQUID_COMMIT"
    (cd "$CACHE/hyprliquid" && make release)
    mkdir -p "$HOME/.local/lib"
    cp "$CACHE/hyprliquid/build/Release/libhyprliquid.so" "$HOME/.local/lib/hyprliquid.so"

    say "Building System Settings"
    cmake -S "$CACHE/revo-shell/SystemSettings" -B "$CACHE/revo-shell/SystemSettings/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build "$CACHE/revo-shell/SystemSettings/build"
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
    cp "$CACHE/revo-shell/SystemSettings/build/systemsettings" "$HOME/.local/bin/"
    cat > "$HOME/.local/share/applications/systemsettings.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=System Settings
Comment=Configure your system
Exec=$HOME/.local/bin/systemsettings
Terminal=false
Categories=Settings;System;
StartupWMClass=systemsettings
Icon=$CACHE/revo-shell/SystemSettings/icons/dt_about.png
EOF
fi

say "Done. Edit ~/.config/hypr/configs/monitors.lua for your screens, then log out and back in."
