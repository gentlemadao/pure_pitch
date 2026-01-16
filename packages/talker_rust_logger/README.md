# Talker Rust Logger

A powerful bridge that pipes **Rust** logs directly into **Flutter's Talker**.

This package allows you to see your Rust crate's logs (`log::info!`, `log::error!`, etc.) directly inside your Flutter app's [Talker](https://pub.dev/packages/talker) debug screen.

> **Note**: This library strictly focuses on bridging logs to **Talker**. It does **not** automatically configure platform logging (Logcat, Console.app, Stdout). If you want native platform logs alongside Talker, you can easily integrate them using `init_with_logger`.

## Features

- 🚀 **Zero-Config Rust Setup**: Auto-generates necessary Rust boilerplate using a CLI tool.
- 🎯 **Focused**: Lightweight, with minimal dependencies. No forced platform logging.
- 📱 **Flutter Integrated**: Pipes all logs to `Talker` with correct log levels and colors.
- 🛡️ **FRB Compatible**: Designed to work seamlessly with `flutter_rust_bridge` (v2+).

## Installation

### 1. Add Dart Dependency

In your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  talker_rust_logger:
    path: packages/talker_rust_logger # Or git/pub dependency
```

### 2. Add Rust Dependency

In your Rust project's `Cargo.toml`:

```toml
[dependencies]
talker_rust_logger = { path = "../packages/talker_rust_logger/rust" } # Or git/crates.io
```

## Setup

Run the setup CLI:

```bash
dart run talker_rust_logger:setup_logger
```

This generates `rust/src/api/logging.rs` in your project with the default template.

## Usage

### 1. Initialize in Dart

```dart
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_rust_logger/talker_rust_logger.dart';
import 'src/rust/api/logging.dart' as frb;

void main() async {
  await RustLib.init();
  final talker = TalkerFlutter.init();

  TalkerRustLogger.init(
    talker: talker,
    logStream: frb.createLogStream(),
    converter: (frb.LogEntry e) => RustLogEntry(
      timeMillis: e.timeMillis.toInt(),
      level: RustLogLevel.values[e.level.index],
      tag: e.tag,
      msg: e.msg,
    ),
  );

  runApp(MyApp());
}
```

## Deep Dive: The Generated Code

The `setup_logger` script generates a file at `rust/src/api/logging.rs`.
Here is the **exact content** of that file. You are free to modify it!

```rust
use crate::frb_generated::StreamSink;

// --- Data Structures (Generated locally for FRB) ---

// 1. You can modify these structs! 
// For example, if you want to add a 'thread_id' field, just add it here
// and update the conversion logic below.
#[derive(Clone, Debug)]
pub enum LogLevel {
    Trace,
    Debug,
    Info,
    Warn,
    Error,
}

#[derive(Clone, Debug)]
pub struct LogEntry {
    pub time_millis: i64,
    pub level: LogLevel,
    pub tag: String,
    pub msg: String,
    // pub thread_id: String, // <--- Example modification
}

// --- Converters ---

impl From<talker_rust_logger::LogLevel> for LogLevel {
    fn from(l: talker_rust_logger::LogLevel) -> Self {
        match l {
            talker_rust_logger::LogLevel::Trace => LogLevel::Trace,
            talker_rust_logger::LogLevel::Debug => LogLevel::Debug,
            talker_rust_logger::LogLevel::Info => LogLevel::Info,
            talker_rust_logger::LogLevel::Warn => LogLevel::Warn,
            talker_rust_logger::LogLevel::Error => LogLevel::Error,
        }
    }
}

impl From<talker_rust_logger::LogEntry> for LogEntry {
    fn from(e: talker_rust_logger::LogEntry) -> Self {
        Self {
            time_millis: e.time_millis,
            level: e.level.into(),
            tag: e.tag,
            msg: e.msg,
            // thread_id: "unknown".to_string(), // <--- Handle new field
        }
    }
}

// --- Log Stream Entry Point ---

pub fn create_log_stream(sink: StreamSink<LogEntry>) {
    let sink = sink.clone();
    
    // Register the callback with the library.
    // NOTE: This initializes the logger to ONLY send logs to Talker (Dart).
    // If you want native platform logs (Logcat/Console) as well, use `init_with_logger`.
    let _ = talker_rust_logger::init(move |entry| {
        let _ = sink.add(entry.into());
    });
}
```

### How to Customize Data Structures

If you modify the `LogEntry` struct in `logging.rs`:
1.  **Add the field** to the struct (e.g., `pub thread_id: String`).
2.  **Update the `From` implementation** to populate that field.
    *   *Note*: The source data comes from `talker_rust_logger::LogEntry`. If the field isn't in the library's base entry, you might need to supply a default value or compute it there.
3.  **Run Codegen**: `flutter_rust_bridge_codegen generate`.
4.  **Update Dart**: Update your `converter` function in Dart to map the new field to your own Dart model or `RustLogEntry`.

## Advanced: Adding Platform Logs (Logcat/Console)

To see logs in your terminal or Android Studio:

1.  Add loggers to `rust/Cargo.toml`:
    ```toml
    [target.'cfg(target_os = "android")'.dependencies]
    android_logger = "0.13"
    [target.'cfg(not(target_os = "android"))'.dependencies]
    env_logger = "0.11"
    ```

2.  Modify `rust/src/api/logging.rs` to use `init_with_logger`:

    ```rust
    pub fn create_log_stream(sink: StreamSink<LogEntry>) {
        let sink = sink.clone();
        
        let platform_logger: Box<dyn log::Log + Send + Sync>;
        
        #[cfg(target_os = "android")]
        {
            platform_logger = Box::new(android_logger::AndroidLogger::new(
                android_logger::Config::default().with_tag("Rust")
            ));
        }
        #[cfg(not(target_os = "android"))]
        {
            platform_logger = Box::new(env_logger::Builder::from_default_env().build());
        }

        let _ = talker_rust_logger::init_with_logger(move |entry| {
            let _ = sink.add(entry.into());
        }, Some(platform_logger));
    }
    ```

## License

MIT OR Apache-2.0
