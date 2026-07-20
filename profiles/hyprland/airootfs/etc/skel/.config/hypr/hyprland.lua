-- Archuseriso default Hyprland config
-- See https://wiki.hypr.land/Configuring/ for the full reference.
-- Since Hyprland 0.55 the configuration uses Lua (hyprlang is deprecated).
-- Requires Hyprland >= 0.55; older versions ignore this file and expect
-- the legacy hyprland.conf instead.
--
-- This is the main entry point. To keep the configuration maintainable the
-- settings live in separate files under the "config/" subdirectory and are
-- loaded from here. Edit the individual modules rather than this file.

-- Make "require" resolve modules relative to this file, so the config works
-- regardless of the current working directory.
local this_dir = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"
package.path = this_dir .. "?.lua;" .. this_dir .. "?/init.lua;" .. package.path

require("config.monitors")     -- Display outputs
require("config.looknfeel")    -- General appearance
require("config.input")        -- Keyboard and touchpad
require("config.windows")      -- Window rules
require("config.autostart")    -- Programs started with the session
require("config.keybindings")  -- Keyboard shortcuts
