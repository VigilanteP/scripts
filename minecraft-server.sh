#!/bin/bash
[ -s "/home/peter/.jabba/jabba.sh" ] && source "/home/peter/.jabba/jabba.sh"
jabba use temurin@17.0.12
cd /opt/bmc4-server
./run.sh
