#!/bin/bash
set -e

# Version configuration
ORT_VERSION="1.23.2"
BASE_URL="https://github.com/microsoft/onnxruntime/releases/download/v${ORT_VERSION}"
TARGET_FILE="libonnxruntime.dylib"

# Determine script directory to handle relative paths correctly
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUTPUT_DIR="${SCRIPT_DIR}/../rust_builder/macos"

echo "Downloading ONNX Runtime v${ORT_VERSION} for macOS..."

# Determine download URL based on architecture (using Universal2 for simplicity on macOS)
DOWNLOAD_URL="${BASE_URL}/onnxruntime-osx-universal2-${ORT_VERSION}.tgz"

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "Using temp dir: $TEMP_DIR"

# Download
curl -L -o "${TEMP_DIR}/ort.tgz" "$DOWNLOAD_URL"

# Extract
tar -xzf "${TEMP_DIR}/ort.tgz" -C "$TEMP_DIR"

# Locate and copy the dylib
# Note: The extracted folder name depends on the archive content
EXTRACTED_LIB="${TEMP_DIR}/onnxruntime-osx-universal2-${ORT_VERSION}/lib/${TARGET_FILE}"

if [ -f "$EXTRACTED_LIB" ]; then
    echo "Found library at $EXTRACTED_LIB"
    mkdir -p "$OUTPUT_DIR"
    cp "$EXTRACTED_LIB" "$OUTPUT_DIR/"
    echo "Successfully copied $TARGET_FILE to $OUTPUT_DIR"
else
    echo "Error: Could not find $TARGET_FILE in downloaded archive."
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"
