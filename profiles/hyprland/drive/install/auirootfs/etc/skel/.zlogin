# Welcome on console after aui-mkinstall / aui-mkhybrid.
# Hyprland is started manually so the TTY remains usable after exit.
if [[ -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} && "$(tty)" == "/dev/tty1" ]]; then
    cat <<EOF

  Archuseriso Hyprland (installed)
  --------------------------------
  Logged in as "${USER}". No password was set at install time
  (same for root). Set one with: passwd

  Start the desktop:
    start-hyprland

  Administrative commands: sudo (wheel). Configure a password first
  if sudo prompts for one.

  After exiting Hyprland you return to this console.
  Super+F1 inside Hyprland shows keyboard shortcuts.

EOF
fi

