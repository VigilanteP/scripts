#!/bin/bash
curl -sS https://starship.rs/install.sh > /tmp/ss.sh
chmod +x /tmp/ss.sh
/tmp/ss.sh --yes
rm /tmp/ss.sh
