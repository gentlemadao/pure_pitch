import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'talker.g.dart';

/// Global talker instance for logging without ref
final talker = TalkerFlutter.init();

@riverpod
Talker talkerInstance(Ref ref) {
  return talker;
}
