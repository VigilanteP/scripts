#!/bin/bash
rm -f zzzcopyscript.sh

source=${1:-"."};
target=${2:-"node_modules"};
artifacts_directory="~/artifacts"

if [ $# -eq 1 ]
  then 
  	target=$1
  	source="."
fi

echo "Checking if $source is a subdirectory of $HOME"
if ! echo $source | grep -Eq "^(~|($HOME).*)"
then
	echo 'Source must be within user $HOME directory: '$source;
	exit;
fi

# path will be used to traverse from the root of the artifacts directory
relative_source=$(echo $source | sed -E "s+~/|($HOME/)++")

# all artifacts will be placed starting from this directory
target_root=$artifacts_directory'/'$relative_source

echo Source is: $source
echo Target is: $target
echo Target root directory is: $target_root

echo Relative source is: $relative_source;
echo Artifacts root directory is: $artifacts_directory

# exec echo 'mkdir -p '$target_root'/$(echo '{}' | sed -E "s+'$source'++" | rev | cut -d / -f 2- | rev)' \; \
# exec echo 'mkdir -p '$target_root'/$(echo '{}' | sed -E "s+'$source/?'++" | rev | cut -d / -f 2- | rev)' \; \

find ~/$relative_source -type d -name $target \
-exec echo 'rm -rf '$target_root'/$(echo '{}' | sed -E "s+'$source/?'++" | rev | cut -d / -f 2- | rev)' \; \
-exec echo 'mkdir -p '$target_root'/$(echo '{}' | sed -E "s+'$source/?'++" | rev | cut -d / -f 2- | rev)' \; \
-exec echo 'mv -f {} '$target_root'/$(echo '{}' | sed -E "s+'$source/?'++" | rev | cut -d / -f 2- | rev)' \; \
-exec echo 'ln -s '$target_root'/$(echo '{}' | sed -E "s+'$source/?'++" | rev | cut -d / -f 2- | rev)' {} \; >> zzzcopyscript.sh

chmod +x zzzcopyscript.sh
echo 'execute ./zzzcopyscript.sh to apply'
#./zzzcopyscript.sh
#rm -f zzzcopyscript.sh