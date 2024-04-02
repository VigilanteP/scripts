#!/bin/sh
mkdir joined
for vid in $(ls *.001); do name=$(basename $vid .001); cat $name.* >> joined/$name; done
