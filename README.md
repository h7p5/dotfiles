# dotfiles

My Arch Linux + Hyprland (Lua config) setup: the **macOS shell from [revo-shell](https://github.com/vzbc/revo-shell)**
with **[hyprliquid](https://github.com/zaregototsukai/hyprliquid)** Liquid Glass, tuned for two monitors
(a 1280x1024 square screen and a 1366x768 wide one).

revo-shell has no license, so this repo does **not** copy its code. It stores only my own files plus small
patches. `install.sh` downloads revo-shell at a pinned commit and applies the patches on top.

## What's changed from stock revo-shell

**Shell (quickshell/macos)**
- Top bar and Dock on **every** monitor, each with its own size (`mainScreenScale` / `secondScreenScale` in `shell.qml`).
- Smaller bars and Dock, scaled inside QML (no `QT_SCALE_FACTOR`, which broke menu placement).
- Top-bar menus (Apple, File, Edit…) open under their labels.
- "About This Mac" is a real floating window: drag it from anywhere, close button works.

**Hyprland**
- `achraf.lua`: personal overrides, loaded last.
  - Keyboard `us,ara`, Alt+Shift to switch.
  - Workspaces: `Super+Ctrl+←/→`, `Super+scroll`, `Super+1..0`, `Super+Shift+1..0`.
  - Resize windows from the keyboard (`Super+=` / `Super+-`, `Super+Ctrl+Shift+arrows`) or by dragging any edge.
  - Fullscreen with `Super+Shift+F`, maximize with `Super+Ctrl+F`.
  - `Super+R` sets a random wallpaper and recolors everything.
- Windows fill the space down to the Dock (exclusive zone).
- Monitors, env and autostart trimmed for a non-NVIDIA machine.

**Wallpaper → colors**
- Changing the wallpaper (`Super+R` or the wallpaper picker) runs **matugen**, which recolors kitty,
  Hyprland, hyprlock and GTK.
- Fixed a hang in `matugen_reload.sh` when swaync isn't running.

**Terminal**
- kitty at font size 11.
- fastfetch with a small **Arch logo whose color follows the wallpaper** (kitty `color4` = matugen primary).

## Install

```bash
git clone https://github.com/h7p5/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh                 # configs only
./install.sh --build-extras  # + build the hyprliquid plugin and the System Settings app
```

It asks before replacing anything and moves your current `~/.config/{hypr,kitty,fastfetch,matugen,quickshell/macos}`
to `~/.config-backup-<date>/`. It never uses sudo.

**Needs:** `hyprland` (Lua config, 0.57+), `quickshell`, `kitty`, `fastfetch`, `matugen`, `awww`, `git`, `patch`, `python`.
For `--build-extras`: `cmake`, `ninja`, Qt 6, and Hyprland headers.
The SF Pro font is not included (Apple license); install it yourself, e.g. `otf-apple-sf-pro` from the AUR.

After installing, edit `~/.config/hypr/configs/monitors.lua` for your own screens.

## Layout

```
install.sh              fetch revo-shell, patch it, install
patches/                my changes to revo-shell (hypr, kitty, quickshell/macos)
config/hypr/achraf.lua  personal Hyprland overrides
config/fastfetch/       Arch logo + info
config/matugen/         matugen config + templates
home/bashrc-snippet.sh  runs fastfetch when kitty opens
```

## Credits

- [revo-shell](https://github.com/vzbc/revo-shell) by vzbc: the shell and Hyprland config this is built on.
- [hyprliquid](https://github.com/zaregototsukai/hyprliquid) by zaregototsukai (BSD-3-Clause).
- matugen templates in `config/matugen/templates` come from
  [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (GPL-3.0).
