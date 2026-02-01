#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

# Override to accept PVE 8.4+ (upstream check only allows 8.1-8.3)
pve_check() {
  if ! pveversion | grep -Eq "pve-manager/8\\.[1-9]"; then
    msg_error "This version of Proxmox Virtual Environment is not supported"
    echo -e "Requires Proxmox Virtual Environment Version 8.1 or later."
    echo -e "Exiting..."
    sleep 2
    exit
  fi
}

function header_info {
clear
cat <<"EOF"
    __  __      __        __        _____                          
   / / / /_  __/ /_____ _/ /__     / ___/___  ______   _____  _____
  / /_/ / / / / __/ __ `/ / _ \    \__ \/ _ \/ ___/ | / / _ \/ ___/
 / __  / /_/ / /_/ /_/ / /  __/   ___/ /  __/ /   | |/ /  __/ /    
/_/ /_/\__, /\__/\__,_/_/\___/   /____/\___/_/    |___/\___/_/     
      /____/                                                       

EOF
}
header_info
echo -e "Loading..."
APP="Hytale Server"
var_disk="20"
var_cpu="2"
var_ram="4096"
var_os="debian"
var_version="12"
variables
var_install="debian-install"
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /opt/hytale ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated ${APP} LXC"
echo -e "\nTo update server files, run: ${BL}/usr/local/bin/hytale-download${CL}"
exit
}

start
build_container
msg_info "Installing ${APP} in container"
pct exec "$CTID" -- bash -c "FUNCTIONS_FILE_PATH=\$(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/install.func); export FUNCTIONS_FILE_PATH; bash -s" < /home/peter/pve-scripts/install/hytaleserver-install.sh
msg_ok "Installed ${APP} in container"
description

msg_ok "Completed Successfully!\n"
echo -e "The server has been installed and enabled as a systemd service.
If this is the first launch, authenticate once with: ${BL}hytale-auth${CL}
To view logs: ${BL}journalctl -u hytale -f${CL}\n"
