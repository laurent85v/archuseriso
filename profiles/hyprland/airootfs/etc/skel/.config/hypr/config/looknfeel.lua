-- Look and feel -- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        layout      = "dwindle",
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
    },

    decoration = {
        rounding = 8,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range   = 4,
            color   = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        -- Keep Hyprland's wallpaper path enabled; hyprpaper sets wall1.png on start.
        -- force_default_wallpaper = 0 and disable_hyprland_logo = true hide the desktop
        -- background when hyprpaper has not applied a wallpaper yet (or fails).
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        focus_on_activate       = true,
    },

    xwayland = {
        force_zero_scaling = true
    },
})
