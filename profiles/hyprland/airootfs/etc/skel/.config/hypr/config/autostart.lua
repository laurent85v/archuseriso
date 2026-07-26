-- Autostart -- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Wallpaper first so the desktop is not left blank while other apps start.
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("xdg-user-dirs-update")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    -- hypridle/hyprlock disabled on the live medium (empty-password unlock issues)
    -- Clipboard history store (cliphist + wl-clipboard)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
