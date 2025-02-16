# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define parameters for video encoding
$videoCodec = "libx265"
$bitRate = "1M"  # Low bitrate for proxies
$maxDimension = 1920

# Define the name for the proxy directory
$ProxyDirName = "Proxy"

# Get the number of CPU cores with exception handling
Try {
    $coreCount = (Get-WmiObject Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
} Catch {
    Write-Host "Error retrieving CPU core count: $_"
    $coreCount = 1  # Default to 1 core if there's an error
}

# Function to process video files in a directory
function Process-VideosInDirectory {
    param (
        [string]$directory
    )

    # Ensure the proxy subdirectory exists
    $proxyDir = Join-Path -Path $directory -ChildPath $ProxyDirName
    if (-not (Test-Path -Path $proxyDir)) {
        Try {
            New-Item -ItemType Directory -Path $proxyDir
        } Catch {
            Write-Host "Error creating proxy directory: $_"
            return
        }
    }

    # Get all video files in the current directory (excluding subdirectories)
    $videoFiles = Get-ChildItem -Path $directory -File | Where-Object {
        $_.Extension -match '\.(mp4|avi|mkv|mov|wmv)$'
    }

    # Check and remove proxies for videos no longer in source directory
    Get-ChildItem -Path $proxyDir -Filter *.mov | ForEach-Object {
        $originalFile = (Get-ChildItem -Path $directory -File | Where-Object { 
            $_.BaseName -eq $_.BaseName -and $_.Name -replace '\.mov$', '' -like $_.Name
        })
        if (-not $originalFile) {
            Remove-Item $_.FullName -Force
            Write-Host "Removed proxy $($_.Name) as original video not found."
        }
    }

    foreach ($file in $videoFiles) {
        # Construct the output file name and path
        $outputFile = Join-Path -Path $proxyDir -ChildPath ($file.BaseName + ".mov")
        $tempOutputFile = $outputFile + ".tmp"
        
        # Check if proxy already exists
        if (Test-Path -Path $outputFile) {
            Write-Host "Proxy for $($file.Name) already exists. Skipping."
            continue
        }
        
        # Use FFmpeg to encode the video with specified parameters
        $ffmpegCommand = "ffmpeg -threads $coreCount -i `"$($file.FullName)`" -c:v $videoCodec -b:v $bitRate -vf `"scale='min($maxDimension, iw)':-2`" -f mov `"$tempOutputFile`""
        
        Write-Host "Creating proxy for $($file.Name)"
        Write-Verbose "FFmpeg command: $ffmpegCommand"
        
        Try {
            Invoke-Expression $ffmpegCommand
            if ($LASTEXITCODE -eq 0) {
                Rename-Item -Path $tempOutputFile -NewName $outputFile
                Write-Host "Proxy created successfully for $($file.Name)"
            } else {
                Write-Host "Failed to create proxy for $($file.Name)"
            }
        } Catch {
            Write-Host "Error creating proxy for $($file.Name): $_"
        }
    }
}

# Recursively process all directories, excluding proxy directories
Get-ChildItem -Path $PSScriptRoot -Recurse -Directory | Where-Object {
    $_.Name -notmatch "^$ProxyDirName$" -and $_.FullName -notmatch "\\$ProxyDirName\\"
} | ForEach-Object {
    Process-VideosInDirectory -directory $_.FullName
}

# Process the root directory as well
Process-VideosInDirectory -directory $PSScriptRoot

Read-Host -Prompt "Press Enter to exit"
