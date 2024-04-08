# Add a batch of torrents to qbittorrent
# Used now to transfer old torrents from Deluge but has many uses
#
# The script takes every torrent in the input directory and adds it to qbittorrent,
# paused, and expecting data at the output directory
# This won't work if you don't have the data already in that directory which is add-paused
# hash match for the associated data defined in the .torrent metadata file
if not set -q argv[1]  
   echo "You must provide a torrent meta source directory."
   return 1
end
set input_directory $argv[1]

if not set -q argv[2] 
   echo "You must provide an torrent data directory."
   return 1
end
set output_directory $argv[2]

if not test -d $input_directory
  echo "Input directory does not exist: "$input_directory
  return 1
end

if not test -d $output_directory
  mkdir -p $output_directory
end

for torrent_file in $input_directory/*.torrent
  echo "Adding $torrent_file"
  qbittorrent-nox --save-path=$output_directory --skip-hash-check --add-paused=true $torrent_file
end
