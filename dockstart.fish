#!/usr/bin/fish
nwg-dock-hyprland -d >/dev/null 2>1 &
disown (jobs -p | string split \n)
