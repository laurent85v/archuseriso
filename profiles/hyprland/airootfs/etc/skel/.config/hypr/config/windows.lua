-- Window rules -- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- System / utility dialogs work better as floating windows on a live medium.
local float_classes = {
    "pavucontrol",
    "org.pulseaudio.pavucontrol",
    "nm-connection-editor",
    "blueman-manager",
    "blueman-adapters",
    "blueman-services",
    "GParted",
    "file-roller",
    "org.gnome.FileRoller",
    "imv",
    "aui-help",
}

for _, class in ipairs(float_classes) do
    hl.window_rule({
        name  = "float-" .. class,
        match = { class = class },
        float = true,
    })
end

-- Ignore maximize requests from clients (keeps tiling predictable).
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
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
