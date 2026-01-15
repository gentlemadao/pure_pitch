// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pure_pitch/core/localization/generated/l10n.dart';
import 'package:pure_pitch/core/services/storage_service.dart';

part 'locale_provider.g.dart';

@riverpod
class AppLocale extends _$AppLocale {
  @override
  Locale build() {
    final savedCode = ref.read(storageServiceProvider).getString('locale');
    if (savedCode != null) {
      return Locale(savedCode);
    }
    
    // Default to system locale if supported, otherwise English
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final supportedLocales = S.delegate.supportedLocales;
    
    for (final locale in supportedLocales) {
      if (locale.languageCode == systemLocale.languageCode) {
        return locale;
      }
    }
    
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(storageServiceProvider).setString('locale', locale.languageCode);
  }
}