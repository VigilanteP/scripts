#!/bin/bash
zellij delete-session -f hytale 2>/dev/null
zellij attach --create-background hytale
zellij run -- bash /home/peter/scripts/hytale-server.sh
