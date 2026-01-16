// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:async';

import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/src/rust/api/logging.dart' as frb;
import 'package:talker_rust_logger/talker_rust_logger.dart';

Future<void> initRustLogging() async {
  // Pass the stream creation function to the library
  TalkerRustLogger.init(
    talker: talker,
    logStream: frb.createLogStream(),
    converter: (frb.LogEntry e) {
      return RustLogEntry(
        timeMillis: e.timeMillis.toInt(),
        level: _mapLevel(e.level),
        tag: e.tag,
        msg: e.msg,
      );
    },
  );
}

RustLogLevel _mapLevel(frb.LogLevel level) {
  switch (level) {
    case frb.LogLevel.trace:
      return RustLogLevel.trace;
    case frb.LogLevel.debug:
      return RustLogLevel.debug;
    case frb.LogLevel.info:
      return RustLogLevel.info;
    case frb.LogLevel.warn:
      return RustLogLevel.warn;
    case frb.LogLevel.error:
      return RustLogLevel.error;
  }
}
