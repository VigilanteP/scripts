#!/bin/bash
if [ -x /usr/local/bin/hytale-auth ]; then
  exec /usr/local/bin/hytale-auth
fi
exec /usr/local/bin/hytale-start
