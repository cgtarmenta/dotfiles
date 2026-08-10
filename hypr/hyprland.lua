-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                     Monitor Configuration                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Monitor wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Positions are calculated based on scaled resolution (physical / scale).
-- Hyprland ignores monitor rules for hardware that isn't connected, so the
-- ROG Flow laptop's internal panel rule below is harmless on this desktop.

-- LG Ultrawide (Primary) - 3440x1440 @ 100Hz at top
hl.monitor({ output = "DP-5", mode = "3440x1440@100", position = "0x0", scale = "1.25" })

-- Kamvas Pro 13 (Drawing Tablet) - 1920x1080 @ 60Hz centered below LG
-- Scaled resolution at 1.25: 1920/1.25 = 1536 x 1080/1.25 = 864
-- LG at 1.25: 3440/1.25 = 2752 x 1440/1.25 = 1152
-- Centered horizontally: X = (2752 - 1536) / 2 = 608, below LG: Y = 1152
hl.monitor({ output = "DP-4", mode = "1920x1080@60", position = "608x1152", scale = "1.25" })

-- ASUS ROG Flow X13 internal display (only relevant on that machine)
hl.monitor({ output = "eDP-2", mode = "1920x1200@120", position = "0x0", scale = "1.5" })

-- Fallback for any other monitors
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1.25" })

------------------------
---- ENVIRONMENT ----
------------------------

-- Electron based apps use X11 as default, auto should detect wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- GDK/GTK scaling for better compatibility
hl.env("GDK_SCALE", "1.5")   -- GDK Scaling Factor
hl.env("GDK_DPI_SCALE", "1") -- Keep DPI at 1 when using GDK_SCALE

-- IMPORTANT: Do NOT set GTK_THEME here; it breaks libadwaita (gedit, nautilus, etc.).
-- Use gsettings instead, e.g.:
--   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
--   gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

-- Keyboard layout environment variable for applications
hl.env("XKB_DEFAULT_LAYOUT", "es")

-------------------
---- AUTOSTART ----
-------------------

-- exec-once equivalent: runs once at compositor start
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/xdg-portal-hyprland")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")           -- The bottom bar
    hl.exec_cmd("blueman-applet")   -- Systray app for BT
    hl.exec_cmd("nm-applet --indicator") -- Systray app for Network/WiFi
    hl.exec_cmd("tailscale up")     -- Connect to Tailscale VPN
end)

-- plain exec equivalent: runs at startup AND re-runs on every config reload.
-- NOTE: unlike the old hyprlang `exec = ...`, the "config.reloaded" event
-- does NOT fire on the initial config load at compositor start (confirmed
-- live: swaybg never launched on first login, only after a manual
-- `hyprctl reload`) — so this has to be wired into both events explicitly.
local function runOnEveryConfigLoad()
    hl.exec_cmd("swaybg -m fill -i ~/.config/hypr/moon-over-mondstat.jpg")
    hl.exec_cmd("swaync")
    hl.exec_cmd("wl-gammarelay")
end

hl.on("hyprland.start", runOnEveryConfigLoad)
hl.on("config.reloaded", runOnEveryConfigLoad)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    xwayland = {
        force_zero_scaling = true, -- Unscale XWayland, let Hyprland handle it
    },

    input = {
        kb_layout = "es",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },

    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = "rgb(cdd6f4)",
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },

    misc = {
        disable_hyprland_logo = true,
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        -- `pseudotile` was removed in Hyprland 0.55; toggle per-window via the `pseudo` dispatcher.
        preserve_split = true, -- required for layoutmsg togglesplit to work
    },

    master = {
        -- "master" | "slave" | "inherit" (string enum). The old .conf had the
        -- boolean `new_status = true`, a leftover from the pre-rename
        -- `new_is_master` variable; "master" preserves that original intent.
        new_status = "master",
    },

    binds = {
        allow_workspace_cycles = 1,
        workspace_back_and_forth = 1,
        workspace_center_on = 1,
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

--------------------
---- WINDOW RULES ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- NOTE on the float rules below: the old hyprland.conf had these as bare
-- `windowrule = match:class ^(x)$` lines with NO action — a leftover from an
-- abandoned v1 migration attempt ("i have no idea why it caused issues to
-- keep them as v1", per the old comment). They were silently doing nothing;
-- the intended `float = true` (visible only in commented-out v2 lines next
-- to them) is restored here. blueman-manager's class regex also had a stray
-- extra colon (`:^(blueman-manager)$`) that's fixed below.

hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(zenity)$" }, float = true })
hl.window_rule({ match = { class = "^(nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(nautilus)$" }, opacity = "0.95 0.8" })
hl.window_rule({ match = { class = "^(rofi)$" }, move = "cursor -3% -105%" })

----------------
---- BINDS -----
----------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

-- Emergency keybinds
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("warp-terminal"))       -- Open terminal (alternative)
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("warp-terminal")) -- Open the terminal
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))           -- Open filemanager
hl.bind(mainMod .. " + Q", hl.dsp.window.close())                 -- Close the active window
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("uwsm stop"))  -- Exit Hyprland session via UWSM
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))     -- Allow a window to float
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))         -- Show the graphical app launcher
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })) -- Toggle fullscreen
hl.bind(mainMod .. " + Y", hl.dsp.window.pin())                   -- Pin window (shows on all workspaces)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))          -- Toggle dwindle split direction
hl.bind(mainMod .. " + K", hl.dsp.group.toggle())                 -- Toggle group mode
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())                 -- Switch to next window in group
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock-fancy -e -K -p 10 -f Hack-Regular")) -- Lock the screen
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("killall -SIGUSR2 waybar")) -- Reload waybar

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(hyprctl activewindow -j | jq -r '.at[0],.at[1],.size[0],.size[1]' | tr '\\n' ' ' | awk '{print $1\",\"$2\" \"$3\"x\"$4}')\" - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("grim - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"))

-- Toggle Gaps
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("hyprctl --batch \"keyword general:gaps_out 5;keyword general:gaps_in 3\""))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("hyprctl --batch \"keyword general:gaps_out 0;keyword general:gaps_in 0\""))

-- Open applications on F-keys
hl.bind(mainMod .. " + SHIFT + F1", hl.dsp.exec_cmd("Telegram"))
hl.bind(mainMod .. " + SHIFT + F2", hl.dsp.exec_cmd("whatsdesk"))
hl.bind(mainMod .. " + SHIFT + F3", hl.dsp.exec_cmd("slack"))
hl.bind(mainMod .. " + SHIFT + F4", hl.dsp.exec_cmd("discord"))
hl.bind(mainMod .. " + SHIFT + F5", hl.dsp.exec_cmd("clickup"))
hl.bind(mainMod .. " + SHIFT + F6", hl.dsp.exec_cmd("steam"))
-- F7 intentionally unbound
hl.bind(mainMod .. " + SHIFT + F8", hl.dsp.exec_cmd("/usr/bin/intellij-idea-ultimate-edition"))
hl.bind(mainMod .. " + SHIFT + F9", hl.dsp.exec_cmd("spotify-launcher"))

-- Changing Screen Temperature with wl-gammarelay
hl.bind(mainMod .. " + CTRL + SHIFT + 0", hl.dsp.exec_cmd("busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500"))
hl.bind(mainMod .. " + CTRL + SHIFT + Down", hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"))
hl.bind(mainMod .. " + CTRL + SHIFT + Up", hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"))

-- Volume Control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("amixer sset Master toggle"), { locked = true, repeating = true })

-- Screen Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Playback Control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Warp Terminal Voice-to-Text
hl.bind("ISO_Level3_Shift", hl.dsp.exec_cmd("warp-terminal --voice-input"))

-- Window Actions - Move window with SHIFT + arrows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Resizing windows - Activate resize mode
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
    hl.bind("left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
    hl.bind("l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
    hl.bind("h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Quick resize window with keyboard
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window and switch to workspace with mainMod + CTRL + [0-9]
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + CTRL + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + CTRL + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + CTRL + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + CTRL + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ workspace = -1 }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ workspace = "+1" }))

-- Move window silently to workspace (without switching) with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + COMMA", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + slash", hl.dsp.focus({ workspace = "previous" }))

-- Special workspaces (scratchpads)
hl.bind(mainMod .. " + minus", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + equal", hl.dsp.workspace.toggle_special("special"))
hl.bind(mainMod .. " + F1", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + SHIFT + F1", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Locks the Screen when being opened/closed
-- hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("swaylock && systemctl suspend"), { locked = true })

-- Change background image
hl.bind(mainMod .. " + SHIFT + SPACE + 1", hl.dsp.exec_cmd("swaybg -m fill -i ~/.config/hypr/moon-over-mondstat.jpg"))
hl.bind(mainMod .. " + SHIFT + SPACE + 2", hl.dsp.exec_cmd("swaybg -m fill -i ~/.config/hypr/sucrose.jpg"))
hl.bind(mainMod .. " + SHIFT + SPACE + 3", hl.dsp.exec_cmd("swaybg -m fill -i ~/.config/hypr/sayu-without-char.jpg"))
hl.bind(mainMod .. " + SHIFT + SPACE + 4", hl.dsp.exec_cmd("swaybg -m fill -i ~/.config/hypr/xiao.jpg"))
