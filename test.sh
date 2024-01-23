#!/bin/bash
source=/Users/pbergeron
if echo $source | grep -e "^$HOME.*"
then
	echo 'found it';
fi

echo 'Source is' $source