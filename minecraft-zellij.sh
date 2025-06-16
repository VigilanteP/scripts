#!/bin/bash
zellij delete-session -f minecraft 2>/dev/null
zellij attach --create-background minecraft
zellij run -- bash /home/peter/minecraft.sh
