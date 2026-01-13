// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';

class PitchVisualizer extends StatefulWidget {
  final List<TimestampedPitch> history;
  final List<NoteEvent> noteEvents;
  final bool isRecording;
  final double visibleTimeWindow;
  final int minNote;
  final int maxNote;

  const PitchVisualizer({
    super.key,
    required this.history,
    this.noteEvents = const [],
    this.isRecording = false,
    this.visibleTimeWindow = 5.0,
    this.minNote = 36, // C2
    this.maxNote = 84, // C6
  });

  @override
  State<PitchVisualizer> createState() => _PitchVisualizerState();
}

class _PitchVisualizerState extends State<PitchVisualizer> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double pixelsPerSecond =
            constraints.maxWidth / widget.visibleTimeWindow;

        // Calculate total width
        double totalWidth = constraints.maxWidth;
        if (widget.noteEvents.isNotEmpty) {
          final lastNote = widget.noteEvents.last;
          totalWidth =
              (lastNote.startTime + lastNote.duration) * pixelsPerSecond + 100;
        }

        // Auto-scroll to the end if recording
        if (widget.isRecording && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          });
        }

        return Container(
          color: const Color(0xFF121212), // Deep background
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: CustomPaint(
              size: Size(
                max(totalWidth, constraints.maxWidth),
                constraints.maxHeight,
              ),
              painter: _PitchPainter(
                history: widget.history,
                noteEvents: widget.noteEvents,
                isRecording: widget.isRecording,
                pixelsPerSecond: pixelsPerSecond,
                visibleTimeWindow: widget.visibleTimeWindow,
                minNote: widget.minNote,
                maxNote: widget.maxNote,
                viewportWidth: constraints.maxWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PitchPainter extends CustomPainter {
  final List<TimestampedPitch> history;
  final List<NoteEvent> noteEvents;
  final bool isRecording;
  final double pixelsPerSecond;
  final double visibleTimeWindow;
  final int minNote;
  final int maxNote;
  final double viewportWidth;

  _PitchPainter({
    required this.history,
    required this.noteEvents,
    required this.isRecording,
    required this.pixelsPerSecond,
    required this.visibleTimeWindow,
    required this.minNote,
    required this.maxNote,
    required this.viewportWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (noteEvents.isNotEmpty) {
      _drawNoteEvents(canvas, size);
    }

    if (isRecording && history.isNotEmpty) {
      _drawLivePitch(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    final octavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;

    for (int i = minNote; i <= maxNote; i++) {
      final y = size.height - ((i - minNote) * heightPerNote);
      final isC = (i % 12) == 0;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isC ? octavePaint : linePaint,
      );

      if (isC) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'C${(i / 12).floor() - 1}',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
      }
    }
  }

  void _drawNoteEvents(Canvas canvas, Size size) {
    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;

    for (final note in noteEvents) {
      final x = note.startTime * pixelsPerSecond;
      final w = note.duration * pixelsPerSecond;
      final y = size.height - ((note.midiNote - minNote + 1) * heightPerNote);

      // Draw note rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + 2, w, heightPerNote - 4),
        const Radius.circular(4),
      );

      // Gradient fill
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      // Shadow
      canvas.drawRRect(
        rect.shift(const Offset(1, 1)),
        Paint()..color = Colors.black45,
      );
      canvas.drawRRect(rect, paint);

      // Border highlight
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawLivePitch(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool isFirst = true;

    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;

    // Live pitch drawing logic: X coordinates based on timestamps
    // Most recent point is on the far right
    final now = history.last.time;
    final windowDurationMs = (visibleTimeWindow * 1000).toInt();

    for (final point in history) {
      final diffMs = now.difference(point.time).inMilliseconds;
      if (diffMs > windowDurationMs) continue;

      // X coordinate: offset from right to left
      final x = size.width - (diffMs / 1000.0 * pixelsPerSecond);

      double fractionalMidi = point.midiNote.toDouble();
      if (point.hz > 0) {
        fractionalMidi = 69 + 12 * (log(point.hz / 440.0) / log(2));
      }
      final y = size.height - ((fractionalMidi - minNote) * heightPerNote);

      if (point.clarity < 0.4) {
        isFirst = true;
        continue;
      }

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw current cursor point
    final last = history.last;
    if (last.clarity >= 0.4) {
      final y = size.height - ((last.midiNote - minNote) * heightPerNote);
      canvas.drawCircle(
        Offset(size.width, y),
        5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(size.width, y),
        8,
        Paint()..color = Colors.cyanAccent.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => true;
}
