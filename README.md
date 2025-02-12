# CreateProxies.ps1

## Overview

`CreateProxies.ps1` is a PowerShell script designed to create low-bitrate proxy videos from high-resolution video files. This script uses FFmpeg to transcode the videos into a more manageable format, making it easier to work with large video files during the editing process. The script also ensures that proxies are kept up-to-date and removes any proxies for videos that no longer exist in the source directory. It uses the Davinci Resolve naming convention so the editing suite should automatically use the proxies if you enable the editor to do so.

All you need to do is throw a copy of this script into any folder where you have videos, then double click on it. 

## Features

- Transcodes high-resolution videos into low-bitrate proxy videos using FFmpeg.
- Supports multiple video formats: `.mp4`, `.avi`, `.mkv`, `.mov`, and `.wmv`.
- Automatically detects the number of CPU cores to optimize FFmpeg performance.
- Ensures the existence of a `proxy` subdirectory for storing proxy files.
- Removes outdated proxies for videos that no longer exist in the source directory.
- Provides real-time progress updates during the transcoding process.
- Licensed under the Apache License, Version 2.0.

## Requirements

- PowerShell
- FFmpeg (must be installed and accessible in the system's PATH)

## Usage

1. **Clone the repository or download the script:**

    ```sh
    git clone https://github.com/your-repo/CreateProxies.git
    cd CreateProxies
    ```

2. **Ensure FFmpeg is installed and accessible:**

    Download and install FFmpeg from [FFmpeg.org](https://ffmpeg.org/download.html) and make sure it is added to your system's PATH.

3. **Run the script:**

    Open a PowerShell terminal and navigate to the directory containing the script. Run the script using the following command:

    ```powershell
    .\CreateProxies.ps1
    ```

## Script Details

### Parameters for Video Encoding

- **Video Codec:** `libx265`
- **Bitrate:** `1M` (Low bitrate for proxies)
- **Maximum Dimension:** `1920`

### Core Count Detection

The script attempts to detect the number of CPU cores to optimize FFmpeg performance. If it fails, it defaults to using a single core.

### Proxy Directory

The script ensures the existence of a [proxy](http://_vscodecontentref_/0) subdirectory in the script's directory. This is where all proxy files are stored.

### Video File Detection

The script scans the current directory for video files with the following extensions: `.mp4`, `.avi`, `.mkv`, `.mov`, and `.wmv`.

### Proxy Management

- **Creation:** The script creates proxy files for each detected video file using FFmpeg.
- **Updating:** If a proxy file already exists, the script skips the creation process for that file.
- **Cleanup:** The script removes proxy files for videos that no longer exist in the source directory.

### Real-Time Progress

The script uses FFmpeg's `-progress` option to provide real-time progress updates during the transcoding process.

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.