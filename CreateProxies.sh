#!/bin/bash

# Define parameters for video encoding
videoCodec="libx265"
bitRate="1M"  # Low bitrate for proxies
maxDimension=1920

# Get the number of CPU cores
coreCount=$(getconf _NPROCESSORS_ONLN)
if [ -z "$coreCount" ]; then
    coreCount=1
fi

# Function to process video files in a directory
process_videos_in_directory() {
    local directory="$1"

    # Ensure the "proxy" subdirectory exists
    local proxyDir="$directory/proxy"
    if [ ! -d "$proxyDir" ]; then
        mkdir -p "$proxyDir"
        if [ $? -ne 0 ]; then
            echo "Error creating proxy directory: $proxyDir"
            return
        fi
    fi

    # Get all video files in the current directory (excluding subdirectories)
    for file in "$directory"/*.{mp4,avi,mkv,mov,wmv}; do
        if [ -f "$file" ]; then
            process_file "$file" "$proxyDir"
        fi
    done
}

process_file() {
    local file="$1"
    local proxyDir="$2"

    # Construct the output file name and path
    local outputFile="$proxyDir/$(basename "$file" | sed 's/\.[^.]*$/.mov/')"
    local tempOutputFile="$outputFile.tmp"

    # Check if proxy already exists
    if [ -f "$outputFile" ]; then
        echo "Proxy for $file already exists. Skipping."
        return
    fi

    # Use FFmpeg to encode the video with specified parameters
    local ffmpegCommand="ffmpeg -threads $coreCount -i \"$file\" -c:v $videoCodec -b:v $bitRate -vf \"scale='min($maxDimension, iw)':-2\" -f mov \"$tempOutputFile\""

    echo "Creating proxy for $file"
    echo "FFmpeg command: $ffmpegCommand"

    # Execute the FFmpeg command
    eval $ffmpegCommand
    if [ $? -ne 0 ]; then
        echo "Failed to create proxy for $file"
        return
    fi

    # Rename the temporary output file to the final output file
    mv "$tempOutputFile" "$outputFile"
    if [ $? -ne 0 ]; then
        echo "Error renaming temporary file for $file"
        return
    fi

    echo "Proxy created successfully for $file"
}

# Recursively process all directories
find . -type d | while read -r directory; do
    process_videos_in_directory "$directory"
done

# Process the root directory as well
process_videos_in_directory "$(pwd)"

read -p "Press Enter to exit"