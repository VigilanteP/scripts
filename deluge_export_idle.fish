#!/usr/bin/fish;
set meta_source_dir $HOME/.config/deluge/state
set meta_export_dir $HOME/torrents/deluge/meta/export
set data_export_dir $HOME/torrents/qbittorrent

set inactive_hashes (dcli info --verbose | deluge_filter_transfers -t 2000)

# pause torrents and move to prepare
dcli "pause $inactive_hashes; move $inactive_hashes $HOME/torrents/qbittorrent"

# copy files from deluge local state to export directory with proper name
for hash in $inactive_hashes
  set torrent_file "$meta_source_dir/$hash.torrent"
  set torrent_name (python3 -c "
    import torrent_parser as tp;
    print(tp.parse_torrent_file('$torrent_file')['info']['name'])
  ")

  echo "Exporting $torrent_name ($hash)"
  
  set -a inactive_paths "$meta_export_dir/$torrent_name.torrent"
  cp "$meta_source_dir/$hash.torrent" "$meta_export_dir/$torrent_name.torrent"
end

qbittorrent-nox --save-path=$data_export_dir --skip-hash-check $inactive_paths

# clean up
rm $meta_export_dir/*.torrent 2>/dev/null
dcli "rm -c $inactive_hashes"
