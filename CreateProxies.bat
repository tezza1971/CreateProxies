@echo off
setlocal enabledelayedexpansion

REM Enable debug mode
set "debug=false"

REM Define parameters for video encoding
set "videoCodec=libx265"
set "bitRate=1M"  REM Low bitrate for proxies
set "maxDimension=1920"

REM Define the name for the proxy directory
set "ProxyDirName=Proxy"

REM List of video file extensions to search for (case-insensitive)
set "videoExtensions=mp4 avi mkv mov wmv"

REM Get the number of CPU cores with exception handling
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value') do set "coreCount=%%a"
if not defined coreCount set "coreCount=1"

if "%debug%"=="true" (
    echo Debug: videoCodec=%videoCodec%
    echo Debug: bitRate=%bitRate%
    echo Debug: maxDimension=%maxDimension%
    echo Debug: ProxyDirName=%ProxyDirName%
    echo Debug: coreCount=%coreCount%
    echo Debug: videoExtensions=%videoExtensions%
)

REM Process the root directory first
call :ProcessVideosInDirectory "%cd%"

REM Recursively process all subdirectories, excluding proxy directories
for /d /r "%cd%" %%d in (*) do (
    if /i not "%%~nxd"=="%ProxyDirName%" (
        if "%debug%"=="true" (
            echo Debug: Entering directory=%%d
        )
        pushd "%%d"
        call :ProcessVideosInDirectory "%%d"
        popd
        if "%debug%"=="true" (
            echo Debug: Exiting directory=%%d
        )
    ) else (
        if "%debug%"=="true" (
            echo Debug: Skipping proxy directory=%%d
        )
    )
)

pause
endlocal
goto :eof

REM Function to process video files in a directory
:ProcessVideosInDirectory
set "directory=%~1"

if "%debug%"=="true" (
    echo Debug: Processing directory=%directory%
)

REM Ensure the proxy subdirectory exists
set "proxyDir=%directory%\%ProxyDirName%"
if not exist "%proxyDir%" (
    mkdir "%proxyDir%"
    if errorlevel 1 (
        echo Error creating proxy directory: %proxyDir%
        goto :eof
    )
)

if "%debug%"=="true" (
    echo Debug: proxyDir=%proxyDir%
)

REM Get all video files in the current directory (excluding subdirectories), case-insensitive
set "foundFiles=false"
for %%e in (%videoExtensions%) do (
    for %%f in ("%directory%\*.%%e") do (
        if exist "%%f" (
            set "file=%%f"
            set "foundFiles=true"
            if "%debug%"=="true" (
                echo Debug: Found file=!file!
            )
            call :ProcessFile "%%f"
        )
    )
)
if "%foundFiles%"=="false" (
    if "%debug%"=="true" (
        echo Debug: No video files found in %directory%
    )
)

goto :eof

:ProcessFile
set "file=%~1"
REM Construct the output file name and path
set "outputFile=%proxyDir%\%~n1.mov"
set "tempOutputFile=%outputFile%.tmp"

if "%debug%"=="true" (
    echo Debug: outputFile=%outputFile%
    echo Debug: tempOutputFile=%tempOutputFile%
)

REM Check if proxy already exists
if exist "%outputFile%" (
    echo Proxy for %file% already exists. Skipping.
    goto :eof
)

REM Use FFmpeg to encode the video with specified parameters
set "ffmpegCommand=ffmpeg -threads %coreCount% -i "%file%" -c:v %videoCodec% -b:v %bitRate% -vf "scale='min(%maxDimension%, iw)':-2" -f mov "%tempOutputFile%""

echo Creating proxy for %file%
echo FFmpeg command: !ffmpegCommand!

REM Execute the FFmpeg command
!ffmpegCommand!
if errorlevel 1 (
    echo Failed to create proxy for %file%
    goto :eof
)

REM Rename the temporary output file to the final output file
rename "%tempOutputFile%" "%outputFile%"
if errorlevel 1 (
    echo Error renaming temporary file for %file%
    goto :eof
)

echo Proxy created successfully for %file%

goto :eof