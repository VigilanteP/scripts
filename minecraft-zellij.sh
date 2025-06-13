#!/bin/bash

zellij kill-session minecraft-session >/dev/null
zellij attach -b minecraft-session && zellij run -- bash ./minecraft.sh
