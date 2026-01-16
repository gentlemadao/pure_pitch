// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
use log::{Level, Metadata, Record, SetLoggerError};
use std::sync::Mutex;
use once_cell::sync::Lazy;
use chrono::Local;

// --- Public Data Structures ---

#[derive(Clone, Debug)]
pub enum LogLevel {
    Trace, Debug, Info, Warn, Error,
}

impl From<Level> for LogLevel {
    fn from(l: Level) -> Self {
        match l {
            Level::Trace => LogLevel::Trace,
            Level::Debug => LogLevel::Debug,
            Level::Info => LogLevel::Info,
            Level::Warn => LogLevel::Warn,
            Level::Error => LogLevel::Error,
        }
    }
}

#[derive(Clone, Debug)]
pub struct LogEntry {
    pub time_millis: i64,
    pub level: LogLevel,
    pub tag: String,
    pub msg: String,
}

// --- Global Callback ---
type LogCallback = Box<dyn Fn(LogEntry) + Send + Sync>;
static LOG_CALLBACK: Lazy<Mutex<Option<LogCallback>>> = Lazy::new(|| Mutex::new(None));

// --- The Logger Implementation ---
struct TalkerLogger {
    // Optional inner logger to forward logs to (e.g. platform logger)
    inner: Option<Box<dyn log::Log + Send + Sync>>,
}

impl TalkerLogger {
    fn new(inner: Option<Box<dyn log::Log + Send + Sync>>) -> Self {
        Self { inner }
    }
}

impl log::Log for TalkerLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        // If inner is present, let it decide, otherwise enable everything that is configured via max_level
        match &self.inner {
            Some(l) => l.enabled(metadata),
            None => true, 
        }
    }

    fn log(&self, record: &Record) {
        // 1. Forward to inner logger (Platform / Console)
        if let Some(l) = &self.inner {
            if l.enabled(record.metadata()) {
                l.log(record);
            }
        }

        // 2. Forward to Talker callback
        if let Ok(guard) = LOG_CALLBACK.lock() {
            if let Some(cb) = guard.as_ref() {
                let entry = LogEntry {
                    time_millis: Local::now().timestamp_millis(),
                    level: record.level().into(),
                    tag: record.target().to_string(),
                    msg: record.args().to_string(),
                };
                cb(entry);
            }
        }
    }

    fn flush(&self) {
        if let Some(l) = &self.inner {
            l.flush();
        }
    }
}

/// Initializes the logger to send logs ONLY to Dart (Talker).
///
/// This will replace the global logger.
pub fn init<F>(callback: F) -> Result<(), SetLoggerError>
where F: Fn(LogEntry) + Send + Sync + 'static
{
    init_with_logger(callback, None)
}

/// Initializes the logger with a callback (for Talker) AND an optional inner logger (e.g. for platform output).
///
/// Example:
/// ```rust
/// // If you want android logs + talker logs:
/// let android_logger = Box::new(android_logger::AndroidLogger::new(...));
/// talker_rust_logger::init_with_logger(cb, Some(android_logger));
/// ```
pub fn init_with_logger<F>(callback: F, inner_logger: Option<Box<dyn log::Log + Send + Sync>>) -> Result<(), SetLoggerError>
where F: Fn(LogEntry) + Send + Sync + 'static
{
    let mut guard = LOG_CALLBACK.lock().unwrap();
    *guard = Some(Box::new(callback));

    // Only set the global logger if it hasn't been set yet.
    // We construct the TalkerLogger which wraps the optional inner logger.
    let logger = TalkerLogger::new(inner_logger);
    
    // Attempt to set logger. If it fails (already set), we ignore the error 
    // because we updated the callback above, which might be what the user wanted on hot-restart.
    // However, if the inner_logger changed, that won't apply if global logger is already set.
    // This is a limitation of the log crate.
    let _ = log::set_boxed_logger(Box::new(logger)).map(|()| log::set_max_level(log::LevelFilter::Debug));
    
    Ok(())
}