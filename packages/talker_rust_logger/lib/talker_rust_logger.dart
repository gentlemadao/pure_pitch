// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:async';
import 'package:talker/talker.dart';

/// Maps Rust log levels to Talker levels.
enum RustLogLevel { trace, debug, info, warn, error }

/// A universal model for Rust log entries.
/// Users should map their FRB-generated log struct to this model.
class RustLogEntry {
  final int timeMillis;
  final RustLogLevel level;
  final String tag;
  final String msg;

  const RustLogEntry({
    required this.timeMillis,
    required this.level,
    required this.tag,
    required this.msg,
  });
}

class RustTalkerLog extends TalkerLog {
  RustTalkerLog(RustLogEntry entry) : super(entry.msg) {
    _title = entry.tag.isEmpty ? 'RUST' : entry.tag;
    _level = _mapLevel(entry.level);
  }

  late final String _title;
  late final LogLevel _level;

  @override
  String get title => _title;

  @override
  LogLevel get logLevel => _level;

  @override
  AnsiPen get pen {
    final pen = AnsiPen();
    switch (_level) {
      case LogLevel.error:
        return pen..red();
      case LogLevel.warning:
        return pen..yellow();
      case LogLevel.info:
        return pen..cyan();
      case LogLevel.debug:
        return pen..magenta();
      case LogLevel.verbose:
        return pen..gray();
      default:
        return pen..white();
    }
  }

  LogLevel _mapLevel(RustLogLevel rustLevel) {
    switch (rustLevel) {
      case RustLogLevel.trace:
        return LogLevel.verbose;
      case RustLogLevel.debug:
        return LogLevel.debug;
      case RustLogLevel.info:
        return LogLevel.info;
      case RustLogLevel.warn:
        return LogLevel.warning;
      case RustLogLevel.error:
        return LogLevel.error;
    }
  }
}

class TalkerRustLogger {
  TalkerRustLogger._(this._talker);

  final Talker _talker;
  StreamSubscription? _subscription;

  /// Initializes the logger bridge.
  ///
  /// [talker]: The Talker instance.
  /// [logStream]: The Stream of LogEntry from your FRB API.
  /// [converter]: Function to convert your FRB LogEntry to [RustLogEntry].
  ///
  /// Example:
  /// ```dart
  /// TalkerRustLogger.init(
  ///   talker: talker,
  ///   logStream: createLogStream(),
  ///   converter: (e) => RustLogEntry(
  ///     timeMillis: e.timeMillis.toInt(),
  ///     level: RustLogLevel.values[e.level.index],
  ///     tag: e.tag,
  ///     msg: e.msg,
  ///   ),
  /// );
  /// ```
  static TalkerRustLogger init<T>({
    required Talker talker,
    required Stream<T> logStream,
    required RustLogEntry Function(T event) converter,
  }) {
    final logger = TalkerRustLogger._(talker);
    logger._startListening(logStream, converter);
    return logger;
  }

  void _startListening<T>(
      Stream<T> stream, RustLogEntry Function(T) converter) {
    _subscription = stream.listen((event) {
      try {
        final entry = converter(event);
        _talker.logCustom(RustTalkerLog(entry));
      } catch (e, s) {
        _talker.handle(e, s, 'Failed to process Rust log entry');
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
