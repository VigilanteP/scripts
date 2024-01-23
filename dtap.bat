@echo off
set root=%1
set outdir=%2

if %1.==. set root=.
if %2.==. set outdir=%USERPROFILE%\Extracted

for /f "delims=" %%A in ('cd') do (\
     set initialdir="%%A"
    )
echo Started in %initialdir%

cd %root%
for /f "delims=" %%A in ('cd') do (
     set outname=%%~nxA
    )
cd %initialdir%

echo Processing from %root% into %outdir%

rem echo Extracting from %root% into %outdir%

rem echo Unzipping all zip files
rem 7z x -y -o%root%\.unzipped %root%\*.zip

rem echo Extracting any rars
rem 7z x -y -o%root%\.unrared %root%\.unzipped\*.rar

rem echo Moving output to directory at %outdir%
rem move %root%\.unrared %outdir%
rem rename %outdir%\.unrared %outname%

rem echo Cleaning up
rem rmdir /s /q %root%\.unzipped