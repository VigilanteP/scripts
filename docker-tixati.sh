docker run -d \
    --name=tixati \
    -p 5800:5800 \
    -p 17844:17844/tcp \
    -p 17844:17844/udp \
    -v /nfs/torrents/tixati:/config:rw \
    -v /nfs/torrents/downloading:/output:rw \
    -v /nfs/torrents:/torrents \
    -v /nfs/library:/library \
    jlesage/tixati
