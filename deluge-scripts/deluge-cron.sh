!/bin/bash
scriptname=deluge-manage
scriptdir=~/deluge-scripts
scriptfile=$scriptdir/${scriptname}.py
logdir=~/deluge-scripts/log
logfile_filtered=$logdir/deluge-manage.log
logfile_verbose=$logdir/deluge-manage-verbose.log
export DELUGE_SCRIPTS_CONFIG=$scriptdir/config.ini

for i in $(seq 1 6)
do
  start=$(date +%s.%N)

  output=$(~/.venv/bin/python3 $scriptfile 2>&1)
  if [[ $output != '' ]]
  then
    echo "$output" | tee -a $logfile_verbose

    filtered=$(echo "$output" | grep -v 127.0.0.1)
    if [[ $filtered != '' ]]
      then echo $filtered >> $logfile_filtered
    fi
  fi

  finish=$(date +%s.%N)
  sleep $(echo "scale=2; 10-($finish-$start)" | bc)
done
