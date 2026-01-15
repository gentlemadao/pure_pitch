// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(count) => "分析完成。找到 ${count} 个音符。";

  static String m1(duration) => "分析时长: ${duration}秒";

  static String m2(error) => "错误: ${error}";

  static String m3(error) => "无法开始录音: ${error}";

  static String m4(value) => "${value} Hz";

  static String m5(fileName) => "正在从缓存加载 ${fileName} 的分析结果";

  static String m6(value) => "MIDI: ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accompanimentLabel": MessageLookupByLibrary.simpleMessage("伴奏"),
    "analysisCompleted": m0,
    "analysisDuration": m1,
    "analyzeAudioFile": MessageLookupByLibrary.simpleMessage("分析音频文件"),
    "analyzingAudio": MessageLookupByLibrary.simpleMessage("正在分析音频..."),
    "appTitle": MessageLookupByLibrary.simpleMessage("Pure Pitch 检测器"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteSession": MessageLookupByLibrary.simpleMessage("删除会话"),
    "deleteSessionConfirmation": MessageLookupByLibrary.simpleMessage(
      "您确定要删除此会话吗？此操作无法撤销。",
    ),
    "error": m2,
    "failedToPlayAccompaniment": MessageLookupByLibrary.simpleMessage("无法播放伴奏"),
    "failedToPlayOriginalAudio": MessageLookupByLibrary.simpleMessage("无法播放原声"),
    "failedToStartCapture": m3,
    "hz": m4,
    "importAccompaniment": MessageLookupByLibrary.simpleMessage("导入伴奏"),
    "loadingCache": m5,
    "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "录音需要麦克风权限。",
    ),
    "midi": m6,
    "noSavedSessions": MessageLookupByLibrary.simpleMessage("没有保存的会话"),
    "readyToRecord": MessageLookupByLibrary.simpleMessage("准备就绪"),
    "savedSessions": MessageLookupByLibrary.simpleMessage("已保存的会话"),
    "toolsAndHistory": MessageLookupByLibrary.simpleMessage("工具与历史"),
    "viewLogs": MessageLookupByLibrary.simpleMessage("查看日志"),
  };
}
