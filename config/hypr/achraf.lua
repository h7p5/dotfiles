-- Achraf: personal overrides on top of revo-shell (ported from the old glyph user.lua, 2026-11-23)
-- Old glyph setup backup: ~/dotfiles-backup-glyph-2026-11-23

hl.config({ input = { kb_layout = "us,ara", kb_options = "grp:alt_shift_toggle", numlock_by_default = true } })

-- Performance (Intel HD 4600 + 2 monitors): uncomment if the PC gets slow
-- hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false } }, animations = { enabled = false } })

-- Super+Enter = terminal (Super+T still works)
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))

-- Super+Ctrl+Left/Right and Super+scroll = previous/next workspace on this monitor
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
hl.bind("CTRL + SUPER + Left",  hl.dsp.focus({ workspace = "r-1" }), { repeating = true })
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" }), { repeating = true })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "r+1" }))

-- Workspaces by PHYSICAL key (code:10..19 = the 1..0 row) so they also work with the Arabic layout
--   Super+N go to N | Super+Shift+N move window to N and follow | Super+Alt+N move window, stay here
for i = 1, 10 do
    local key, code = tostring(i % 10), "code:" .. (9 + i)
    hl.unbind("SUPER + " .. key)
    hl.unbind("SUPER + SHIFT + " .. key)
    hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind("SUPER + ALT + " .. code, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Super+M = Spotify (revo had minimize there: moved to Super+Alt+M)
hl.unbind("SUPER + M")
hl.bind("SUPER + M", hl.dsp.exec_cmd("spotify"))
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("/usr/bin/python3 " .. (os.getenv("HOME") or "") .. "/.config/hypr/scripts/minimize_window.py min"))

-- Super+A = region screenshot (revo's Super+A needs skwd, not installed)
hl.unbind("SUPER + A")
hl.bind("SUPER + A", hl.dsp.exec_cmd("hyprshot -m region"))

-- Super+E = Thunar (nautilus is not installed)
hl.unbind("SUPER + E")
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))

-- ── Window size & fullscreen (2026-11-23) ──────────────────────────
--   Super + =  / Super + -              bigger / smaller (hold to repeat)
--   Super+Ctrl+Shift + arrows           wider/narrower, taller/shorter
--   Super+Shift+F                       real fullscreen (hides the bars)
--   Super+Ctrl+F                        maximize (bars stay visible)
--   Super+F                             float on/off (revo), Super+right-drag resizes with the mouse
local function grow(dx, dy)
    return function() hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true })) end
end
hl.unbind("SUPER + minus")   -- was "screenshot of a window" in revo (Print / Super+A still take screenshots)
hl.bind("SUPER + equal", grow(40, 40),  { repeating = true })
hl.bind("SUPER + minus", grow(-40, -40), { repeating = true })
hl.bind("SUPER + CTRL + SHIFT + right", grow(40, 0),  { repeating = true })
hl.bind("SUPER + CTRL + SHIFT + left",  grow(-40, 0), { repeating = true })
hl.bind("SUPER + CTRL + SHIFT + down",  grow(0, 40),  { repeating = true })
hl.bind("SUPER + CTRL + SHIFT + up",    grow(0, -40), { repeating = true })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + CTRL + F",  hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Mouse: drag any window EDGE to resize it (no key needed); grab area 15px around the border
hl.config({ general = { resize_on_border = true, extend_border_grab_area = 15 } })

-- Wallpapers: Super+Y = wallpaper browser (revo), Super+R = random wallpaper
-- (revo's Super+R also restarted its old Main/TopBar shells on top of macos)
hl.unbind("SUPER + R")
hl.bind("SUPER + R", hl.dsp.exec_cmd("bash " .. (os.getenv("HOME") or "") .. "/.config/hypr/scripts/wallpapers/set-random.sh"))

-- About This Mac (macos shell): floating, centered, no border
hl.window_rule({ match = { title = "^About This Mac$" }, float = true, center = true, border_size = 0, no_shadow = true })
