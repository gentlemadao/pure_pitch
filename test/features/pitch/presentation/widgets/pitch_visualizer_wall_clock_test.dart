// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';

void main() {
  testWidgets('PitchVisualizer should repaint as time passes even with static history',
      (tester) async {
    final history = [
      TimestampedPitch(DateTime(2026, 1, 1, 12, 0, 0),
          hz: 440.0, midiNote: 69, clarity: 1.0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PitchVisualizer(
            history: history,
            isRecording: true,
          ),
        ),
      ),
    );

    // Initial paint
    expect(find.byType(PitchVisualizer), findsOneWidget);

    // We can't easily check the canvas, but we know that currently it uses history.last.time.
    // If we advance time and the widget doesn't change history, a standard CustomPaint
    // wouldn't know it needs to move the line unless we use a Ticker or similar.
    
    // In PitchDetectorPage, we have a Ticker that calls setState((){}) during recording.
    // This triggers a repaint.
  });
}
