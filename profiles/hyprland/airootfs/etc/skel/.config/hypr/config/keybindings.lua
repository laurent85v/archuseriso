-- Keybindings -- https://wiki.hypr.land/Configuring/Basics/Binds/

local programs = require("config.programs")
local term = programs.term
local menu = programs.menu
local file_manager = programs.file_manager
local browser = programs.browser
local editor = programs.editor
local mod  = "SUPER"

hl.bind(mod .. " + Return",    hl.dsp.exec_cmd(term))
hl.bind(mod .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",         hl.dsp.exec_cmd(file_manager))
hl.bind(mod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + N",         hl.dsp.exec_cmd(editor))
hl.bind(mod .. " + Q",         hl.dsp.window.close())
-- Alias matching the official Hyprland example (Super+C closes the active window).
hl.bind(mod .. " + C",         hl.dsp.window.close())
-- Confirm then exit (same path as the Waybar power button).
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("aui-hypr-exit"))
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + F1",        hl.dsp.exec_cmd("aui-hypr-help"))

-- Clipboard history (cliphist)
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wmenu -i -p clipboard -l 10 | cliphist decode | wl-copy"))

-- Move/resize the active window with mod + LMB/RMB drag
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move focus
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move focused window
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Workspaces 1-10
-- Bind by physical key code so switching works on any layout (e.g. AZERTY needs
-- Shift for digit keysyms). code:10 = "1" ... code:18 = "9", code:19 = "0".
for i = 1, 10 do
    local code = (i == 10) and 19 or (i + 9)
    hl.bind(mod .. " + code:" .. code,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = i }))
end

-- Screenshots (grim + slurp + clipboard + notification)
hl.bind("Print",               hl.dsp.exec_cmd("aui-screenshot"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("aui-screenshot --region"))

-- Media and brightness keys
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),            { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),             { locked = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),        { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),          { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                      { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                        { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                            { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                     { locked = true })
