#!/bin/bash

# trim leading dot
newext=`echo $2 | sed -E 's/^\.//'`

# replace anything after the last dot with the provided extension in arg $2
newfile=`echo $1 | sed -E 's/\.[^\.]*$/.'$newext'/'`

mv "$1" "$newfile"