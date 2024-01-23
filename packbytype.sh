#!/bin/bash
rootpath=$(pathname.sh "$1")
ext=${2:-$(extname.sh "$1")}

name=$(basename -s .$ext "$1")

echo "$rootpath" "$name" "$ext"

mkdir -p "$rootpath/$ext"
mv "$1" "$rootpath/$ext"