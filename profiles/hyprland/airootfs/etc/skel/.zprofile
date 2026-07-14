# Start Hyprland automatically on the first console login
if [[ -z $DISPLAY ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
        exec start-hyprland
fi
