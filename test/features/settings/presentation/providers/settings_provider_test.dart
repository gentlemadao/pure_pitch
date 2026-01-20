// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_pitch/core/services/storage_service.dart';
import 'package:pure_pitch/features/settings/presentation/providers/settings_provider.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('SettingsNotifier', () {
    test('should default showVocalActivity to false', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(settingsProvider);
      expect(state.showVocalActivity, isFalse);
    });

    test('toggleVocalActivity should update state and persist', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      await notifier.toggleVocalActivity(true);
      expect(container.read(settingsProvider).showVocalActivity, isTrue);
      expect(prefs.getBool('showVocalActivity'), isTrue);

      await notifier.toggleVocalActivity(false);
      expect(container.read(settingsProvider).showVocalActivity, isFalse);
      expect(prefs.getBool('showVocalActivity'), isFalse);
    });
  });
}
