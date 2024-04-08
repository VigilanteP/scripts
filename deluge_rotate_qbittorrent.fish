set qbittorrent_data_dir /media/storage/qbittorrent/downloads/deluge
set torrent_meta_dir /home/peter/torrents/deluge/meta/export

# Get the torrents we want to move via filtering ratio and activity timestamp
set hashes (deluge_transfers | deluge_filter_transfers -r 1 -t 30)

# Move to the output directory qbittorrent works from
dcli move $hashes $torrent_meta_dir 

# Export metadata restoring original metafile name
string split $hashes | deluge_export_meta $torrent_meta_dir

# Pull into qbittorrent
source ~/scripts/qbittorrent_import.fish $torrent_meta_dir $qbittorrent_data_dir

# Finally clean them out of deluge
dcli rm -c $hashes
