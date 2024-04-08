@echo off
doskey ls=eza $*
doskey ll=eza -lagH $*
doskey tree=eza --tree $*
doskey clink="%PROGRAMFILES(X86)%\clink\clink_x64.exe" $*
doskey history=clink history $*
doskey find="%CYGROOT%\bin\find.exe"
