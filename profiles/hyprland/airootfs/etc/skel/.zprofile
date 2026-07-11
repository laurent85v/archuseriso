# Hint starting Hyprland
if [[ -z $DISPLAY ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
        echo
        echo 'To start Hyprland, simply type start-hyprland in the Linux console.'
        echo
fi
