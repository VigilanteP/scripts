#!/usr/bin/fish
function check_time_over_threshold -a input_time threshold_minutes
if (not set -q DELUGE_USER) -o (not set -q DELUGE_PASS)
  echo "set -x DELUGE_USER and DELUGE_PASS dummy."


  # Skip unsupported formats like 'Never' or '∞'
  if test "$input_time" = 'Never' -o "$input_time" = '∞'
      return 1 # Fail - Unsupported format 
  end

  # Initialize variables to 0
  set -l hours 0
  set -l minutes 0

  # Check and extract hours and minutes if present
  if string match -qr '(\d+)h' -- $input_time
      set hours (string match -r '(\d+)h' $input_time)[2]
  end

  if string match -qr '(\d+)m' -- $input_time
      set minutes (string match -r '(\d+)m' $input_time)[2]
  end

  # If no hours or minutes found, assume the input_time is in seconds and skip
  if test $hours -eq 0 -a $minutes -eq 0
      return 1 # Fail - Assume input is in seconds or unsupported
  end

  # Calculate the total time in minutes
  set -l total_time (math "$hours * 60 + $minutes")

  # Check if total time exceeds threshold
  if test $total_time -ge $threshold_minutes
      return 0 # Success - Over threshold
  end
  return 1 # Fail - Not over threshold
end

set -l lastTransferThresholdMinutes 360 # default 6 hours in minutes
if set -q $argv[1]
  set lastTransferThresholdMinutes $argv[1]
end

# Execute the command and process its output directly
dcli info --verbose | while read -l line
    # Handle capturing of ID
  if echo $line | string match -q 'ID:*'
    set currentID (string replace 'ID: ' '' -- $line)
  else if echo $line | string match -q 'Last Transfer:*'
    # Pre-process the line to ensure valid input for trimming
    set lastTransfer (string replace 'Last Transfer: ' '' -- $line)
    if test "$lastTransfer" = 'Never' -o "$lastTransfer" = '∞'
        continue # Skip to next line in the input
    end

    # Check if the time is over the threshold
    if check_time_over_threshold $lastTransfer $lastTransferThresholdMinutes
      echo "Adding $currentID to export list - Last Transfer: $lastTransfer"
      set -a inactiveHashes $currentID
    end
  end
end

# pause torrent and move to prepare
dcli "pause $inactiveHashes; move $inactiveHashes $HOME/torrents/qbittorrent"

# copy files from deluge local state to export directory with proper name
for hash in $inactiveHashes
  set torrent_file "$HOME/.config/deluge/state/$hash.torrent"
  set torrent_name (python3 -c "import torrent_parser as tp; print(tp.parse_torrent_file('$torrent_file')['info']['name'])")
  echo "Exporting $torrent_name ($hash)"
  set -a inactiveNames "$HOME/torrents/meta/export/$torrent_name.torrent"
  cp "$HOME/.config/deluge/state/$hash.torrent" "$HOME/torrents/meta/export/$torrent_name.torrent"
end

# add torrents to destination client skipping the hash check
qbittorrent-nox --save-path=$HOME/torrents/qbittorrent --skip-hash-check --add-paused=true $inactiveNames

# clean up
rm $HOME/torrents/meta/export/*.torrent
dcli -u $DELUGE_USER -P $DELUGE_PASS 'rm -c $inactiveHashes'
