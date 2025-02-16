# CreateProxies

## Overview

`CreateProxies` is a set of scripts designed to create low-bitrate proxy videos from high-resolution video files. These scripts use FFmpeg to transcode the videos into a more manageable format, making it easier to work with large video files during the editing process. The scripts also ensure that proxies are kept up-to-date and remove any proxies for videos that no longer exist in the source directory. They use the Davinci Resolve naming convention so the editing suite should automatically use the proxies if you enable the editor to do so.

All you need to do is throw a copy of the appropriate script into any folder where you have videos, then double click on it.

## Features

- Transcodes high-resolution videos into low-bitrate proxy videos using FFmpeg.
- Supports multiple video formats: `.mp4`, `.avi`, `.mkv`, `.mov`, and `.wmv`.
- Automatically detects the number of CPU cores to optimize FFmpeg performance.
- Ensures the existence of a `proxy` subdirectory for storing proxy files.
- Removes outdated proxies for videos that no longer exist in the source directory.
- Provides real-time progress updates during the transcoding process.
- Licensed under the Apache License, Version 2.0.

## Requirements

- FFmpeg (must be installed and accessible in the system's PATH)

## Usage

### Windows

1. **Clone the repository or download the script:**

    ```sh
    git clone https://github.com/your-repo/CreateProxies.git
    cd CreateProxies
    ```

2. **Ensure FFmpeg is installed and accessible:**

    Download and install FFmpeg from [FFmpeg.org](https://ffmpeg.org/download.html) and make sure it is added to your system's PATH.

3. **Run the script:**

    Double-click the [CreateProxies.bat](https://github.com/tezza1971/CreateProxies/blob/main/CreateProxies.bat) file to execute the script.
    Or use the [PowerShell version](https://github.com/tezza1971/CreateProxies/blob/main/CreateProxies.ps1) (more robust) by executing it with 
    ```sh
    powershell -ExecutionPolicy Bypass -File CreateProxies.ps1
    ```

### macOS and Linux

1. **Clone the repository or download the script:**

    ```sh
    git clone https://github.com/your-repo/CreateProxies.git
    cd CreateProxies
    ```

2. **Ensure FFmpeg is installed and accessible:**

    Download and install FFmpeg from [FFmpeg.org](https://ffmpeg.org/download.html) and make sure it is added to your system's PATH.

3. **Set executable permissions for the script:**

    ```sh
    chmod +x CreateProxies.sh
    ```

4. **Run the script:**

    Double-click the [CreateProxies.sh](http://_vscodecontentref_/2) file or run it from the terminal:

    ```sh
    ./CreateProxies.sh
    ```

## Script Details

### Parameters for Video Encoding

- **Video Codec:** `libx265`
- **Bitrate:** `1M` (Low bitrate for proxies)
- **Maximum Dimension:** `1920`

### Core Count Detection

The scripts attempt to detect the number of CPU cores to optimize FFmpeg performance. If they fail, they default to using a single core.

### Proxy Directory

The scripts ensure the existence of a [proxy](http://_vscodecontentref_/3) subdirectory in the script's directory. This is where all proxy files are stored.

### Video File Detection

The scripts scan the current directory for video files with the following extensions: `.mp4`, `.avi`, `.mkv`, `.mov`, and `.wmv`.

### Proxy Management

- **Creation:** The scripts create proxy files for each detected video file using FFmpeg.
- **Updating:** If a proxy file already exists, the scripts skip the creation process for that file.
- **Cleanup:** The scripts remove proxy files for videos that no longer exist in the source directory.

### Real-Time Progress

The scripts use FFmpeg's `-progress` option to provide real-time progress updates during the transcoding process.

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.