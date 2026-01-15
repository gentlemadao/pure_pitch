// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/app.dart';
import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_pitch/core/services/storage_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter errors
  FlutterError.onError = (details) =>
      talker.handle(details.exception, details.stack);

  // Catch Platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  final prefs = await SharedPreferences.getInstance();
  await RustLib.init();
  await initOrt();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: TalkerRiverpodLoggerSettings(
            providerFilter: (provider) {
              final name = provider.name;
              // Ignore high-frequency updates from the pitch provider
              return name != 'pitchProvider';
            },
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
