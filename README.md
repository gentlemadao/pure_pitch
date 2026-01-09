# PurePitch

![License](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-green)
![Build Status](https://github.com/unilumin/pure_pitch/actions/workflows/build.yml/badge.svg)

PurePitch is a cross-platform vocal pitch testing tool built with **Flutter** and **Rust**. It leverages the performance of Rust for audio processing while providing a beautiful native UI via Flutter.

Supported Platforms: **Android, iOS, Windows, MacOS, Linux**.

## Features

* Real-time vocal pitch detection.
* High-performance audio processing using Rust.
* Cross-platform support.

## Development Setup

### Prerequisites

* **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
* **Rust Toolchain**: [Install Rust](https://www.rust-lang.org/tools/install)
* **Just**: [Install Just](https://github.com/casey/just) (Command runner)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/pure_pitch.git
   cd pure_pitch
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Code Generation:**
   We use `build_runner` and `intl_utils` for code generation. You can run the predefined command in `Justfile`:
   ```bash
   just build
   ```
   Or manually:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter pub run intl_utils:generate
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

### Project Structure

* `lib/`: Flutter Dart code.
* `rust/`: Rust library code (business logic & audio processing).
* `rust_builder/`: Helper package to build the Rust library for Flutter.
* `conductor/`: Project documentation and design guidelines.

## License

Licensed under either of

* Apache License, Version 2.0 ([LICENSE](LICENSE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE](LICENSE) or http://opensource.org/licenses/MIT)

at your option.