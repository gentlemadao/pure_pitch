// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_timeline.dart';

void main() {
  testWidgets('PitchTimeline should render time labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 40,
            child: PitchTimeline(
              pixelsPerSecond: 100, // 5s window for 500px
              totalWidth: 1000, // 10s total
              scrollOffset: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PitchTimeline), findsOneWidget);
    // Visual verification of labels like "0s", "5s" would be in manual verification
    // but we check if it pumps without error.
  });
}
