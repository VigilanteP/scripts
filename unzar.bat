@echo OFF
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

echo Extracting from %root% into %outdir%

echo Unzipping all zip files
7z x -y -o%root%\.unzipped %root%\*.zip

echo Extracting any rars
7z x -y -o%root%\.unrared %root%\.unzipped\*.rar

echo Moving output to directory at %outdir%
move %root%\.unrared %outdir%
rename %outdir%\.unrared %outname%

echo Cleaning up
rmdir /s /q %root%\.unzipped