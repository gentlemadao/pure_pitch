// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'talker.g.dart';

/// Global talker instance for logging without ref
final talker = TalkerFlutter.init();

@riverpod
Talker talkerInstance(Ref ref) {
  return talker;
}
