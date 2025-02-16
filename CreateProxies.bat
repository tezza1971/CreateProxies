@echo off
setlocal

:: Define parameters for video encoding
set "videoCodec=libx265"
set "bitRate=1M"  :: Low bitrate for proxies
set "maxDimension=1920"

:: Get the number of CPU cores with exception handling
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value') do set "coreCount=%%a"
if not defined coreCount set "coreCount=1"

:: Function to process video files in a directory
:ProcessVideosInDirectory
set "directory=%~1"

:: Ensure the "proxy" subdirectory exists
set "proxyDir=%directory%\proxy"
if not exist "%proxyDir%" (
    mkdir "%proxyDir%"
    if errorlevel 1 (
        echo Error creating proxy directory: %proxyDir%
        goto :eof
    )
)

:: Get all video files in the current directory (excluding subdirectories)
for %%f in ("%directory%\*.mp4" "%directory%\*.avi" "%directory%\*.mkv" "%directory%\*.mov" "%directory%\*.wmv") do (
    set "file=%%f"
    call :ProcessFile
)

goto :eof

:ProcessFile
:: Construct the output file name and path
set "outputFile=%proxyDir%\%~n1.mov"
set "tempOutputFile=%outputFile%.tmp"

:: Check if proxy already exists
if exist "%outputFile%" (
    echo Proxy for %file% already exists. Skipping.
    goto :eof
)

:: Use FFmpeg to encode the video with specified parameters
set "ffmpegCommand=ffmpeg -threads %coreCount% -i "%file%" -c:v %videoCodec% -b:v %bitRate% -vf "scale='min(%maxDimension%, iw)':-2" -f mov "%tempOutputFile%""

echo Creating proxy for %file%
echo FFmpeg command: %ffmpegCommand%

:: Execute the FFmpeg command
%ffmpegCommand%
if errorlevel 1 (
    echo Failed to create proxy for %file%
    goto :eof
)

:: Rename the temporary output file to the final output file
rename "%tempOutputFile%" "%outputFile%"
if errorlevel 1 (
    echo Error renaming temporary file for %file%
    goto :eof
)

echo Proxy created successfully for %file%

goto :eof

:: Recursively process all directories
for /r %%d in (.) do (
    if exist "%%d" (
        call :ProcessVideosInDirectory "%%d"
    )
)

:: Process the root directory as well
call :ProcessVideosInDirectory "%cd%"

pause
endlocal