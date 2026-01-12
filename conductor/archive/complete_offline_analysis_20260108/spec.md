# Track Spec: Complete Offline Audio Analysis Pipeline

## Context
We need to implement the offline audio analysis feature using the **Basic Pitch** ONNX model. The system currently has a skeleton for audio decoding and DSP, but lacks the actual model integration and post-processing.

## Goal
Enable the application to take an audio file path, process it through the Basic Pitch model using the Rust `ort` library, and return a list of `NoteEvent`s (MIDI notes) to the Flutter UI for visualization.

## Requirements

### 1. Model Integration
*   **Model Path**: `/Volumes/M2/PythonProjects/basic_pitch.onnx` (Will need to be copied to assets).
*   **Input Node**: `input_2`
    *   Expected Shape: `[Batch, Time, 1]`. We need to verify if `43844` is a fixed requirement or if it handles variable lengths. Typically Basic Pitch processes ~3s windows.
    *   Data: Audio samples (resampled to 22,050 Hz).
*   **Output Nodes**:
    *   `note`: `[Batch, Time, 88]` (MIDI probability 0-1).
    *   `onset`: `[Batch, Time, 88]` (Onset probability 0-1).
    *   `contour`: `[Batch, Time, 264]` (Pitch bend/contour).

### 2. Rust Core Implementation
*   **Resampling**: Ensure audio is strictly resampled to 22,050 Hz using `rubato`.
*   **Preprocessing**: Flatten/Shape the audio buffer to match `[1, N, 1]`.
*   **Inference**: Use `ort` to run the session.
*   **Post-processing**:
    *   Thresholding: Apply 0.3 threshold (configurable) to `note` output.
    *   Peak Picking: Identify note events from probabilities.
    *   MIDI Conversion: Convert bin indices to MIDI numbers (approx `index + 21`).

### 3. Flutter UI Integration
*   **Asset Management**: Ensure the ONNX model is accessible to the Rust core (bundle in assets or pick from file).
*   **Visualization**: Update `PitchVisualizer` to draw the returned `NoteEvent`s (rectangles) on top of or instead of the real-time pitch line.

## Technical Details
*   **Dependencies**: `ort`, `ndarray`, `rubato`, `symphonia` (Already added).
*   **Performance**: Model loading should happen once or lazily. Inference should run in a separate thread (handled by FRB).
