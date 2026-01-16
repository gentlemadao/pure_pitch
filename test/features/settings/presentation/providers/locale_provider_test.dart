// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:pure_pitch/features/settings/presentation/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_pitch/core/services/storage_service.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('AppLocaleNotifier should default to English', () {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final locale = container.read(appLocaleProvider);
    expect(locale, equals(const Locale('en')));
  });

  test('AppLocaleNotifier should update locale', () {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(appLocaleProvider.notifier);

    notifier.setLocale(const Locale('zh'));
    expect(container.read(appLocaleProvider), equals(const Locale('zh')));

    notifier.setLocale(const Locale('en'));
    expect(container.read(appLocaleProvider), equals(const Locale('en')));
  });
}
