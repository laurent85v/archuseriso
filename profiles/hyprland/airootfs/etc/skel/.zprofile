# Welcome message for the live user on the console.
# Hyprland is started manually so the console remains available after exit.
if [[ -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} && "$(tty)" == "/dev/tty1" ]]; then
    cat <<'EOF'

  Archuseriso Hyprland live session
  ---------------------------------
  You are logged in as user "live". No password is configured
  for "live" or "root".

  Start the desktop:
    start-hyprland

  Run administrative commands with sudo (no password required):
    sudo <command>

  Examples:
    sudo pacman -Syu
    sudo gparted

  After exiting Hyprland you return to this console.
  Super+F1 inside Hyprland shows keyboard shortcuts.

EOF
fi
