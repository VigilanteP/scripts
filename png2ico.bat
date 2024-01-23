@echo off
if %1.==. (
     echo Missing argument
     exit
)

set source=%1
set target=%2
if %2.==. set target=%1.ico

magick -background transparent "%source%" -define icon:auto-resize=16,24,32,48,64,72,96,128,256 "%target%"