// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pure_pitch/core/services/storage_service.dart';
import 'package:pure_pitch/features/settings/domain/models/settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    final storage = ref.watch(storageServiceProvider);
    final showVocalActivity = storage.getBool('showVocalActivity') ?? false;

    return SettingsState(showVocalActivity: showVocalActivity);
  }

  Future<void> toggleVocalActivity(bool value) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setBool('showVocalActivity', value);
    state = state.copyWith(showVocalActivity: value);
  }
}
