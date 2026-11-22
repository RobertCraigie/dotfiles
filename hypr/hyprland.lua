-- Refer to the wiki for more information.
-- https://wiki.hypr.land/configuring/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "modeline 1188.000 3840 4016 4104 4400 2160 2168 2178 2250 +hsync +vsync",
    position = "0x0",
    scale    = 1,
})
-- Fallback for any other display that gets plugged in
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Disable the laptop panel while the lid is closed with an external display
-- (logind ignores the lid when docked), and turn it back on otherwise.
-- hl.monitor merges into the existing rule for an output, so `disabled` has
-- to be reset explicitly.
local EDP = {
    output   = "eDP-1",
    mode     = "3840x2400@120",
    position = "auto-down",
    scale    = 2,
    disabled = false,
}

local function sh(cmd)
    local p = io.popen(cmd)
    local out = p:read("*a")
    p:close()
    return out
end

local function docked_with_lid_closed()
    if not sh("cat /proc/acpi/button/lid/*/state"):find("closed") then
        return false
    end
    local status = sh([[for f in /sys/class/drm/card*-*/status; do case "$f" in *eDP*) ;; *) cat "$f" ;; esac; done]])
    return ("\n" .. status):find("\nconnected") ~= nil
end

local edp_retry

local function apply_lid_state()
    if edp_retry then
        edp_retry:set_enabled(false)
        edp_retry = nil
    end

    if docked_with_lid_closed() then
        hl.monitor({ output = "eDP-1", disabled = true })
        return
    end

    hl.monitor(EDP)

    -- Hyprland can report eDP-1 as on while its modeset failed (seen when the
    -- lid opened during an external display hotplug), leaving the panel blank
    -- until it is toggled. Retry until the kernel agrees it is enabled.
    local attempts = 0
    edp_retry = hl.timer(function()
        attempts = attempts + 1
        local enabled = sh("cat /sys/class/drm/card*-eDP-1/enabled"):find("^enabled")
        if enabled or attempts >= 5 then
            edp_retry:set_enabled(false)
            edp_retry = nil
            return
        end
        hl.monitor({ output = "eDP-1", disabled = true })
        hl.monitor(EDP)
    end, { timeout = 1000, type = "repeat" })
end

if docked_with_lid_closed() then
    hl.monitor({ output = "eDP-1", disabled = true })
else
    hl.monitor(EDP)
end


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "fuzzel"
local browser     = "glide"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_THEME", "Adwaita") -- installed by home.pointerCursor in nixos/home.nix
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- How much to dim the rest of the screen when a special workspace is open (default 0.2)
        dim_special = 0.05,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- See https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- Bind workspaces 1-10 to HDMI when present; they fall back to eDP-1 automatically when it's unplugged.
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = i == 1 })
end

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = 0x938288,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        repeat_delay = 200,
        repeat_rate  = 30,

        follow_mouse = 1,

        -- Allow focus to fall through to the regular workspace when the
        -- active special workspace contains only floating windows (e.g. notes).
        special_fallthrough = true,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
            scroll_factor  = 0.5,
        },
    },

    gestures = {
        workspace_swipe_distance           = 500, -- px of swipe to switch workspace
        workspace_swipe_min_speed_to_force = 40,  -- px/ms flick threshold
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

local TERMINAL_CLASSES = {
    ["kitty"] = true,
    ["org.wezfurlong.wezterm"] = true,
    ["Alacritty"] = true,
    ["alacritty"] = true,
    ["foot"] = true,
    ["footclient"] = true,
    ["com.mitchellh.ghostty"] = true,
    ["st-256color"] = true,
    ["xterm-256color"] = true,
    ["wezterm"] = true,
}

local function clipboard_shortcut(key)
    return function()
        local window = hl.get_active_window()
        local mods = (window and TERMINAL_CLASSES[window.class]) and "CTRL SHIFT" or "CTRL"
        hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key }))
    end
end

-- Focus the most-recently-used window of `class`, or launch `cmd` if none exist.
local function focus_or_launch(class, cmd)
    return function()
        local best
        for _, window in ipairs(hl.get_windows()) do
            if window.class == class and (not best or window.focus_history_id < best.focus_history_id) then
                best = window
            end
        end
        if best then
            hl.dispatch(hl.dsp.focus({ window = best }))
        else
            hl.exec_cmd(cmd)
        end
    end
end

-- Cycle focus; if the previously active window was fullscreen, fullscreen the new one too.
local function cycle_keep_fullscreen(next)
    return function()
        local previous = hl.get_active_window()
        local was_fullscreen = previous and previous.fullscreen ~= 0

        hl.dispatch(hl.dsp.window.cycle_next({ next = next }))

        local current = hl.get_active_window()
        if was_fullscreen and current then
            hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 2, client = current.fullscreen_client }))
        end
    end
end

-- Floating notes scratchpad
local function toggle_notes()
    for _, window in ipairs(hl.get_windows()) do
        if window.class == "notes" then
            hl.dispatch(hl.dsp.workspace.toggle_special("notes"))
            return
        end
    end
    hl.exec_cmd([[NVIM_NOTES=1 kitty --class notes --override tab_bar_min_tabs=999 ]]
        .. [[-e nvim -c "set laststatus=0 showtabline=0 cmdheight=0 ruler! showmode!" ]]
        .. [["$HOME/Documents/Obsidian/notes.md"]])
end

-- See https://wiki.hypr.land/configuring/core/binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("noctalia-shell ipc call sessionMenu toggle"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", focus_or_launch("glide-glide", browser))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + C", clipboard_shortcut("C"))
hl.bind(mainMod .. " + V", clipboard_shortcut("V"))
hl.bind(mainMod .. " + A", hl.dsp.send_shortcut({ mods = "CTRL", key = "A" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())           -- dwindle
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + up/down arrows or HJKL (left/right switch workspaces below)
hl.bind(mainMod .. " + up",   hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",    hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",    hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",    hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + TAB",         cycle_keep_fullscreen(true))
hl.bind(mainMod .. " + SHIFT + TAB", cycle_keep_fullscreen(false))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + ALT + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + left",    hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + right",   hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + N", toggle_notes)

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down",          hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up",            hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + bracketleft",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- resize with keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("switch:on:Lid Switch",  apply_lid_state, { locked = true })
hl.bind("switch:off:Lid Switch", apply_lid_state, { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name  = "notes-scratchpad",
    match = { class = "^(notes)$" },

    float     = true,
    size      = "40% 50%",
    center    = true,
    workspace = "special:notes",
})

hl.window_rule({
    name  = "spotify-workspace",
    match = { class = "^(spotify)$" },

    workspace = "8",
})
