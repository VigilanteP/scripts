#!/bin/bash
source=${1:-.};

find $source -type l -name .yarn -delete
find $source -type l -name node_modules -delete
find $source -type l -name build -delete
