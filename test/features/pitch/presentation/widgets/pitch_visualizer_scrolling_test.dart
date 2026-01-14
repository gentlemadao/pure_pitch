// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'package:clock/clock.dart';

void main() {
  testWidgets('PitchVisualizer should auto-scroll to the end during recording',
      (tester) async {
    final startTime = DateTime(2026, 1, 1, 12, 0, 0);
    
    // Create history spanning 10 seconds.
    // Default visible window is 5s, so it should scroll.
    final history = [
      TimestampedPitch(startTime, hz: 440.0, midiNote: 69, clarity: 1.0),
      TimestampedPitch(startTime.add(const Duration(seconds: 10)), hz: 440.0, midiNote: 69, clarity: 1.0),
    ];

    await withClock(Clock.fixed(startTime.add(const Duration(seconds: 10))), () async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: PitchVisualizer(
                history: history,
                isRecording: true,
                visibleTimeWindow: 5.0,
              ),
            ),
          ),
        ),
      );

      // Trigger a frame to ensure LayoutBuilder runs and scroll controller attaches
      tester.binding.scheduleFrame();
      await tester.pumpAndSettle(); 

      final scrollable = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      final controller = scrollable.controller!;
      
      // pixelsPerSecond = 500 / 5 = 100
      // recordingX = 10s * 100 = 1000
      // targetOffset = max(0.0, 1000 - (500 - 50)) = 1000 - 450 = 550
      expect(controller.offset, closeTo(550.0, 1.0));
    });
  });

  testWidgets('PitchVisualizer should allow manual scrolling after recording stops',
      (tester) async {
    final startTime = DateTime(2026, 1, 1, 12, 0, 0);
    final history = [
      TimestampedPitch(startTime, hz: 440.0, midiNote: 69, clarity: 1.0),
      TimestampedPitch(startTime.add(const Duration(seconds: 10)), hz: 440.0, midiNote: 69, clarity: 1.0),
    ];

    await withClock(Clock.fixed(startTime.add(const Duration(seconds: 10))), () async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: PitchVisualizer(
                history: history,
                isRecording: false, // Stopped
                visibleTimeWindow: 5.0,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(SingleChildScrollView);
      final scrollable = tester.widget<SingleChildScrollView>(scrollableFinder);
      final controller = scrollable.controller!;

      // Initial offset should be 0 because auto-scroll is disabled when isRecording: false
      expect(controller.offset, equals(0.0));

      // Attempt to scroll manually
      await tester.drag(scrollableFinder, const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0.0));
    });
  });
}
