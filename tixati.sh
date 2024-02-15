#!/bin/bash
docker run -d     --name=tixati     -p 5800:5800     -p 17844:17844/tcp     -p 17844:17844/udp     -v /root/tixati:/config:rw     -v /nfs/torrents/downloading:/output:rw     -v /nfs/torrents:/torrents:rw     -v /nfs/library:/library:rw     jlesage/tixati
