#!/bin/bash

zellij delete-session minecraft-session 2>/dev/null
zellij attach -b minecraft-session && zellij run -- bash /home/peter/minecraft.sh
