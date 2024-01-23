if [[ $# -eq 0 ]]
then
	echo Must provide a filename to convert
	exit
fi

convert -background transparent "$1" -define icon:auto-resize=16,24,32,48,64,72,96,128,256 "${2:-$1.ico}"