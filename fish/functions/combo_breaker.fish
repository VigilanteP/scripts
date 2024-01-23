function combo_breaker
	set key "~"
	set interrupt "!"
	set maxlen 5

	set buf (commandline -b)
	echo "buf $buf" >> ot.o

	if [ (string sub -s -1 (echo $buf)) != $key ]
		commandline -i $interrupt
		return
	end

	set combo_len (echo $buf | rev | sed "s/^\($key*\)[^$key].*\$/\1/" | string length)
	echo "Combo shattered after a stunning streak of $combo_len" >> ot.o

	switch $combo_len
	case "1"
		commandline -b "cd $WINHOME"
	case "2"
		commandline -b "cd $APPS"
	case "3"
		commandline -b "cd $DEV"
	end

	commandline -f execute
end