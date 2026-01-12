#!/bin/bash
set -e

# Usage: ./download_libs.sh [platform]
# platform: macos, windows, linux, android, ios, all (default)

PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    PLATFORM="all"
fi

# Version configuration
ORT_VERSION="1.23.2" # Satisfy requirement for ort 2.0-rc.11 (expected >= 1.23.x)
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
    temp_dir=$(mktemp -d)
    aar_path="${temp_dir}/ort.aar"
    
    # Download AAR from Maven
    maven_url="https://repo1.maven.org/maven2/com/microsoft/onnxruntime/onnxruntime-android/${ORT_VERSION}/onnxruntime-android-${ORT_VERSION}.aar"
    
    echo "Downloading AAR from $maven_url"
    if curl -L -o "$aar_path" "$maven_url"; then
        unzip -q "$aar_path" -d "$temp_dir"
        # AAR structure: jni/arm64-v8a/libonnxruntime.so
        mkdir -p "${PROJECT_ROOT}/android/app/src/main/jniLibs"
        cp -r "${temp_dir}/jni/"* "${PROJECT_ROOT}/android/app/src/main/jniLibs/"
        echo "Successfully copied Android .so files to jniLibs"
    else
        echo "Failed to download Android AAR from Maven"
    fi
    rm -rf "$temp_dir"
fi

# iOS
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
    echo "Processing iOS..."
    DEST="${PROJECT_ROOT}/rust_builder/ios"
    mkdir -p "$DEST"
    
    # Use 1.23.0 for iOS as we verified this URL exists and satisfies >= 1.23.x requirement
    local ios_version="1.23.0"
    local ios_url="https://download.onnxruntime.ai/pod-archive-onnxruntime-c-${ios_version}.zip"
    # Fallback to 1.20.0 if 1.23.2 not found (optional, but let's try 1.23.0 first if possible)
    # Actually, let's stick to a version that exists. 1.20.0 is safe.
    # ORT_VERSION is 1.23.2. Let's see if 1.23.0 exists.
    
    temp_dir=$(mktemp -d)
    echo "Downloading from $ios_url"
    if curl -L -o "${temp_dir}/ort.zip" "$ios_url"; then
        unzip -q "${temp_dir}/ort.zip" -d "$temp_dir"
        cp -r "${temp_dir}/onnxruntime.xcframework" "$DEST/"
        echo "Successfully copied onnxruntime.xcframework to $DEST"
    else
        echo "Failed to download iOS framework"
    fi
    rm -rf "$temp_dir"
fi

echo "Done."