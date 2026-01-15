// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Analysis completed. Found ${count} notes.";

  static String m1(duration) => "Analysis duration: ${duration}s";

  static String m2(error) => "Error: ${error}";

  static String m3(error) => "Failed to start capture: ${error}";

  static String m4(value) => "${value} Hz";

  static String m5(fileName) =>
      "Loading analysis results from cache for ${fileName}";

  static String m6(value) => "MIDI: ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accompanimentLabel": MessageLookupByLibrary.simpleMessage("Acc."),
    "analysisCompleted": m0,
    "analysisDuration": m1,
    "analyzeAudioFile": MessageLookupByLibrary.simpleMessage(
      "Analyze Audio File",
    ),
    "analyzingAudio": MessageLookupByLibrary.simpleMessage(
      "Analyzing audio...",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Pure Pitch Detector"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteSession": MessageLookupByLibrary.simpleMessage("Delete Session"),
    "deleteSessionConfirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this session? This action cannot be undone.",
    ),
    "error": m2,
    "failedToPlayAccompaniment": MessageLookupByLibrary.simpleMessage(
      "Failed to play accompaniment",
    ),
    "failedToPlayOriginalAudio": MessageLookupByLibrary.simpleMessage(
      "Failed to play original audio",
    ),
    "failedToStartCapture": m3,
    "hz": m4,
    "importAccompaniment": MessageLookupByLibrary.simpleMessage("Import Acc."),
    "loadingCache": m5,
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone permission is required to record.",
    ),
    "midi": m6,
    "noSavedSessions": MessageLookupByLibrary.simpleMessage(
      "No saved sessions",
    ),
    "readyToRecord": MessageLookupByLibrary.simpleMessage("Ready to Record"),
    "savedSessions": MessageLookupByLibrary.simpleMessage("Saved Sessions"),
    "toolsAndHistory": MessageLookupByLibrary.simpleMessage("Tools & History"),
    "viewLogs": MessageLookupByLibrary.simpleMessage("View Logs"),
  };
}
