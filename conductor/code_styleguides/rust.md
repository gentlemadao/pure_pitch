# Rust Style Guide

## Core Principles
*   **Safety**: Pure Rust implementation. No C/C++ bindings unless wrapped. No Python.
*   **Performance**: Minimize cloning. Use slices `&[f32]` where possible. Pre-allocate vectors.

## Interop (Flutter Rust Bridge)
*   **Communication**: Use `flutter_rust_bridge` (v2).
*   **Error Handling**: Use `anyhow::Result`. Propagate errors to Dart.

## DSP & Audio
*   **Implementation**: Manual STFT/Spectrogram using `rustfft` and `ndarray`.
*   **Forbidden**: High-level DSP libraries (e.g., `librosa`) or GPL libraries.
*   **Pipeline**: `symphonia` (decode) -> `rubato` (resample) -> `rustfft` (process) -> `ort` (inference).

## Documentation
*   **Language**: All comments and documentation must be in English.
*   **Header**: All files must start with the license header:
    ```rust
    // Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
    // SPDX-License-Identifier: MIT OR Apache-2.0
    ```
