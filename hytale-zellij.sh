#!/bin/bash
set -euo pipefail
zellij delete-session -f hytale 2>/dev/null || true
zellij attach --create-background hytale
zellij --session hytale run -- /usr/local/bin/hytale-start
