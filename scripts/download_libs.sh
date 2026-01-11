#!/bin/bash
set -e

# Usage: ./download_libs.sh [platform]
# platform: macos, windows, linux, android, ios, all (default)

PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    PLATFORM="all"
fi

ORT_VERSION="1.23.2" # Matching ort 2.0-rc.11 requirement
BASE_URL="https://github.com/microsoft/onnxruntime/releases/download/v${ORT_VERSION}"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT="${SCRIPT_DIR}/.."

download_and_extract() {
    local url=$1
    local extract_cmd=$2
    local filter=$3
    local dest=$4
    
    echo "Downloading from $url..."
    local temp_dir=$(mktemp -d)
    
    if curl -L -o "${temp_dir}/archive" "$url"; then
        echo "Extracting..."
        if [ "$extract_cmd" == "tar" ]; then
            tar -xzf "${temp_dir}/archive" -C "$temp_dir"
        elif [ "$extract_cmd" == "zip" ]; then
            unzip -q "${temp_dir}/archive" -d "$temp_dir"
        fi
        
        # Find and move files
        find "$temp_dir" -name "$filter" -exec cp {} "$dest" \;
        echo "Copied matching '$filter' to $dest"
    else
        echo "Failed to download $url"
        rm -rf "$temp_dir"
        return 1
    fi
    rm -rf "$temp_dir"
}

# macOS
if [[ "$PLATFORM" == "macos" || "$PLATFORM" == "all" ]]; then
    echo "Processing macOS..."
    DEST="${PROJECT_ROOT}/rust_builder/macos"
    mkdir -p "$DEST"
    download_and_extract \
        "${BASE_URL}/onnxruntime-osx-universal2-${ORT_VERSION}.tgz" \
        "tar" \
        "libonnxruntime.dylib" \
        "$DEST"
fi

# Linux (x64)
if [[ "$PLATFORM" == "linux" || "$PLATFORM" == "all" ]]; then
    echo "Processing Linux..."
    DEST="${PROJECT_ROOT}/linux/lib" # Destination needs to be configured in CMake
    mkdir -p "$DEST"
    download_and_extract \
        "${BASE_URL}/onnxruntime-linux-x64-${ORT_VERSION}.tgz" \
        "tar" \
        "libonnxruntime.so*" \
        "$DEST"
fi

# Windows (x64)
if [[ "$PLATFORM" == "windows" || "$PLATFORM" == "all" ]]; then
    echo "Processing Windows..."
    DEST="${PROJECT_ROOT}/windows/runner" # Needs to be next to executable or in path
    mkdir -p "$DEST"
    download_and_extract \
        "${BASE_URL}/onnxruntime-win-x64-${ORT_VERSION}.zip" \
        "zip" \
        "onnxruntime.dll" \
        "$DEST"
fi

# Android
if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
    echo "Processing Android..."
    # Android uses AAR or specific android build. 
    # Usually we need to extract jniLibs from onnxruntime-android.aar
    # But GitHub releases for 1.20.0 might not have AAR directly attached or named differently.
    # Often it's on Maven. 
    # For simplicity, we can try to download the android release tgz if available, otherwise skip or warn.
    # Checked: 1.16+ has onnxruntime-android-...aar in releases sometimes.
    # Alternatively, download specific arch libs.
    
    # We will use the 'onnxruntime-android' package from Maven Central usually, 
    # but for manual bundling we need .so files.
    # Let's skip Android manual download for now and rely on Gradle or `ort` crate's capabilities
    # UNLESS we explicitly need to bundle .so in jniLibs manually.
    # If we use `ort` with `load-dynamic`, we DO need the .so files.
    
    echo "Android .so download not fully automated in this script yet. Recommended to use Gradle dependency or ort built-in."
fi

# iOS
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
    echo "Processing iOS..."
    # iOS typically uses static linking via podspec or XCFramework.
    echo "iOS configuration handled via Podspec/Xcode."
fi

echo "Done."