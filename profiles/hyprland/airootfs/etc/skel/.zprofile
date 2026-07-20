# Start Hyprland automatically on the first console login.
# Guard against nested sessions and non-tty1 logins.
if [[ -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} && "$(tty)" == "/dev/tty1" ]]; then
    exec start-hyprland
fi
