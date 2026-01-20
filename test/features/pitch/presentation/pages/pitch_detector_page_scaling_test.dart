// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/features/pitch/presentation/pages/pitch_detector_page.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';

import 'package:pure_pitch/core/localization/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_pitch/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('PitchDetectorPage Scaling', () {
    testWidgets('Zoom buttons exist and update state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: PitchDetectorPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state check (might be overridden by LayoutBuilder)
      final context = tester.element(find.byType(PitchDetectorPage));
      final container = ProviderScope.containerOf(context);

      // Find zoom buttons
      final zoomIn = find.byIcon(Icons.zoom_in);
      final zoomOut = find.byIcon(Icons.zoom_out);

      expect(zoomIn, findsOneWidget);
      expect(zoomOut, findsOneWidget);

      // Tap zoom out (increase time window)
      final initialWindow = container.read(pitchProvider).visibleTimeWindow;
      await tester.tap(zoomOut);
      await tester.pumpAndSettle();

      // Expect increase
      expect(
        container.read(pitchProvider).visibleTimeWindow,
        greaterThan(initialWindow),
      );

      // Tap zoom in (decrease time window)
      await tester.tap(zoomIn);
      await tester.pumpAndSettle();
      expect(container.read(pitchProvider).visibleTimeWindow, initialWindow);
    });
  });
}
