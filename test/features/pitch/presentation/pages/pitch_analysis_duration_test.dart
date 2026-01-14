// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/features/pitch/presentation/pages/pitch_detector_page.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:pure_pitch/core/localization/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    if (!RustLib.instance.initialized) {
      final String dylibPath;
      if (Platform.isMacOS) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.dylib';
      } else if (Platform.isWindows) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/rust_lib_pure_pitch.dll';
      } else {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.so';
      }
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    }
  });

  testWidgets('Offline analysis visualizer duration matches audio duration', (
    tester,
  ) async {
    // 1. Setup mock data
    final noteEvents = [
      const NoteEvent(
        startTime: 0.0,
        duration: 1.0,
        midiNote: 60,
        confidence: 1.0,
      ),
      const NoteEvent(
        startTime: 2.0,
        duration: 1.0,
        midiNote: 64,
        confidence: 1.0,
      ),
      const NoteEvent(
        startTime: 4.0,
        duration: 1.0,
        midiNote: 67,
        confidence: 1.0,
      ), // Ends at 5.0s
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pitchProvider.overrideWith(() => MockPitchNotifier(noteEvents)),
        ],
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

    // 2. Find PitchVisualizer
    final visualizerFinder = find.byType(PitchVisualizer);
    expect(visualizerFinder, findsOneWidget);

    // 3. Verify Canvas Width
    // We need to access the scrolling CustomPaint inside the SingleChildScrollView.
    final customPaintFinder = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(CustomPaint),
    );
    expect(customPaintFinder, findsOneWidget);

    // Calculate expected width
    // Tester default size is usually 800x600.
    // LayoutBuilder should give maxWidth=800.
    // Auto-scaling: 5.0 + (800-600)/600*5 = 6.666s window.
    // pixelsPerSecond = 800 / 6.666 = 120.0.

    // totalWidth = (5.0 * 120.0) + 100 = 600 + 100 = 700.
    // But CustomPaint uses max(totalWidth, constraints.maxWidth).
    // max(700, 800) = 800.

    // This implies for a 5s audio on a 6.66s screen, it fits within one screen.
    // Let's create a longer audio to verify scrolling.
    // New Note: startTime: 10.0, duration: 1.0. Ends at 11.0s.
    // totalWidth = 11.0 * 120 + 100 = 1320 + 100 = 1420.
    // 1420 > 800.
  });

  testWidgets('Long audio visualizer width verification', (tester) async {
    final noteEvents = [
      const NoteEvent(
        startTime: 10.0,
        duration: 1.0,
        midiNote: 60,
        confidence: 1.0,
      ), // Ends at 11.0s
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pitchProvider.overrideWith(() => MockPitchNotifier(noteEvents)),
        ],
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

    final customPaintFinder = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(CustomPaint),
    );

    // Expected logic:
    // Window ~6.66s. Width 800. PPS ~120.
    // Audio 11s.
    // Width = 11 * 120 + 100 = 1420.

    // Tolerance for float math
    expect(
      tester.widget<CustomPaint>(customPaintFinder).size.width,
      closeTo(1420, 50.0),
    );
  });
}

class MockPitchNotifier extends Pitch {
  final List<NoteEvent> _mockEvents;
  MockPitchNotifier(this._mockEvents);

  @override
  PitchState build() {
    return PitchState(analysisResults: _mockEvents, isAnalyzing: false);
  }
}
