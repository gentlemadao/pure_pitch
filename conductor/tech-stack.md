# Technology Stack

## License
*   **MIT OR Apache-2.0**: The entire project is dual-licensed under MIT or Apache-2.0.
*   **License Header**: Every source file (`.dart`, `.rs`) MUST include the following header:
    ```
    // Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
    // SPDX-License-Identifier: MIT OR Apache-2.0
    ```
*   **Restriction**: Use of GPL-licensed libraries is strictly forbidden.

## Core
*   **Language**: Dart (Flutter) & Rust
*   **Bridge**: `flutter_rust_bridge` (v2) - High-level safe bindings between Dart and Rust.

## Frontend (Flutter)
*   **Framework**: Flutter
*   **State Management**: `riverpod` & `riverpod_generator` - strictly using code generation for type safety.
*   **Routing**: `go_router` & `go_router_builder` - Declarative routing with code generation.
*   **Data Modeling**: `freezed` & `json_serializable` - Immutable data classes (mandatory `abstract class` or `sealed class`).
*   **Localization**: `intl` - Mandatory for all UI strings (ARB based).
*   **Local Storage**:
    *   Key-Value: `shared_preferences` (via StorageService).
    *   Database: `sqflite` (via DBManager).

## Backend (Rust Core)
*   **Language**: Pure Rust (No C/C++ bindings unless wrapped in safe Rust, NO Python).
*   **Audio Pipeline**:
    *   **Decoding**: `symphonia` (MP3/WAV/AAC decoding).
    *   **Resampling**: `rubato` (Resampling to 22,050 Hz).
    *   **DSP**: `rustfft` & `ndarray` (Manual STFT/Spectrogram implementation).
    *   **AI Inference**: `ort` (ONNX Runtime for Basic Pitch model).
    *   **Pitch Detection**: `pitch-detection` (McLeod algorithm for real-time tracking).

## Infrastructure & Tooling
*   **Build System**: `build_runner` (Dart), `cargo` (Rust).
*   **Task Runner**: `just` (Command orchestration: `just check`, `just l10n`, etc.).
*   **Linting**: `flutter_lints` & static analysis.
