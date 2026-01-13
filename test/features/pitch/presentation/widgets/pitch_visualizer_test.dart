import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart'; // For NoteEvent

void main() {
  testWidgets('PitchVisualizer renders NoteEvents', (
    WidgetTester tester,
  ) async {
    final noteEvents = [
      const NoteEvent(
        startTime: 0.0,
        duration: 1.0,
        midiNote: 60,
        confidence: 0.9,
      )
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PitchVisualizer(
            history: const [],
            noteEvents: noteEvents,
          ),
        ),
      ),
    );

    // Verify it renders. Since it's CustomPaint, visual verification is hard in unit test.
    // But we check if it pumps without error.
    expect(find.byType(PitchVisualizer), findsOneWidget);
  });
}
