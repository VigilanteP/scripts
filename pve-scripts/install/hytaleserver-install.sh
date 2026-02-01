#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y unzip
$STD apt-get install -y gpg
$STD apt-get install -y ca-certificates
msg_ok "Installed Dependencies"

msg_info "Installing Temurin Java 25"
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor >/etc/apt/keyrings/adoptium.gpg
CODENAME="$(awk -F= '/^VERSION_CODENAME=/{print $2}' /etc/os-release)"
echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${CODENAME} main" >/etc/apt/sources.list.d/adoptium.list
$STD apt-get update
$STD apt-get install -y temurin-25-jdk
msg_ok "Installed Temurin Java 25"

msg_info "Setting up Hytale directories"
install -d /opt/hytale
install -d /opt/hytale/downloader
msg_ok "Created Hytale directories"

msg_info "Downloading Hytale downloader"
cd /opt/hytale/downloader
curl -fsSLO https://downloader.hytale.com/hytale-downloader.zip
unzip -o hytale-downloader.zip >/dev/null
chmod +x /opt/hytale/downloader/hytale-downloader-linux-amd64
msg_ok "Downloaded Hytale downloader"

msg_info "Downloading Hytale server files"
cd /opt/hytale/downloader
./hytale-downloader-linux-amd64 -download-path /opt/hytale/game.zip
msg_ok "Downloaded Hytale server files"

msg_info "Extracting Hytale server files"
rm -rf /opt/hytale/package
mkdir -p /opt/hytale/package
unzip -o /opt/hytale/game.zip -d /opt/hytale/package >/dev/null
rm -f /opt/hytale/game.zip
rm -rf /opt/hytale/Server /opt/hytale/Assets.zip
mv /opt/hytale/package/Server /opt/hytale/Server
mv /opt/hytale/package/Assets.zip /opt/hytale/Assets.zip
rm -rf /opt/hytale/package
msg_ok "Extracted Hytale server files"

msg_info "Creating helper scripts"
cat <<'EOF' >/usr/local/bin/hytale-download
#!/usr/bin/env bash
set -euo pipefail
cd /opt/hytale/downloader
./hytale-downloader-linux-amd64 -download-path /opt/hytale/game.zip
rm -rf /opt/hytale/package
mkdir -p /opt/hytale/package
unzip -o /opt/hytale/game.zip -d /opt/hytale/package >/dev/null
rm -f /opt/hytale/game.zip
rm -rf /opt/hytale/Server /opt/hytale/Assets.zip
mv /opt/hytale/package/Server /opt/hytale/Server
mv /opt/hytale/package/Assets.zip /opt/hytale/Assets.zip
rm -rf /opt/hytale/package
EOF
chmod +x /usr/local/bin/hytale-download

cat <<'EOF' >/usr/local/bin/hytale-start
#!/usr/bin/env bash
set -euo pipefail
cd /opt/hytale
if [[ ! -f /opt/hytale/Server/HytaleServer.jar ]]; then
  echo "Missing /opt/hytale/Server/HytaleServer.jar"
  exit 1
fi
if [[ ! -f /opt/hytale/Assets.zip ]]; then
  echo "Missing /opt/hytale/Assets.zip"
  exit 1
fi
exec java -XX:AOTCache=/opt/hytale/Server/HytaleServer.aot -jar /opt/hytale/Server/HytaleServer.jar --assets /opt/hytale/Assets.zip
EOF
chmod +x /usr/local/bin/hytale-start

cat <<'EOF' >/usr/local/bin/hytale-auth
#!/usr/bin/env bash
set -euo pipefail
systemctl stop hytale.service >/dev/null 2>&1 || true
/usr/local/bin/hytale-start
EOF
chmod +x /usr/local/bin/hytale-auth
msg_ok "Created helper scripts"

msg_info "Creating service"
cat <<'EOF' >/etc/systemd/system/hytale.service
[Unit]
Description=Hytale Dedicated Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/hytale
ExecStart=/usr/local/bin/hytale-start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable -q hytale.service
msg_ok "Created service"

msg_info "Starting ${APP}"
systemctl start hytale.service
msg_ok "Started ${APP}"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
