// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clock/clock.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'package:pure_pitch/features/pitch/domain/utils/pitch_coordinate_mapper.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_timeline.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/vocal_activity_chart.dart';

class PitchVisualizer extends StatefulWidget {
  final List<TimestampedPitch> history;
  final List<NoteEvent> noteEvents;
  final bool isRecording;
  final double visibleTimeWindow;
  final int minNote;
  final int maxNote;
  final bool showVocalActivity;

  const PitchVisualizer({
    super.key,
    required this.history,
    this.noteEvents = const [],
    this.isRecording = false,
    this.visibleTimeWindow = 5.0,
    this.minNote = 36, // C2
    this.maxNote = 84, // C6
    this.showVocalActivity = false,
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

        // Calculate dynamic range based on both datasets
        // Minimum range restriction: B2 (47) to A4 (69)
        int minD = 47;
        int maxD = 69;

        for (final p in widget.history) {
          if (p.clarity > 0.4 && p.midiNote > 0) {
            if (p.midiNote < minD) minD = p.midiNote;
            if (p.midiNote > maxD) maxD = p.midiNote;
          }
        }
        for (final e in widget.noteEvents) {
          if (e.midiNote < minD) minD = e.midiNote;
          if (e.midiNote > maxD) maxD = e.midiNote;
        }

        // Add padding of 5 semitones
        int effectiveMinNote = max(0, minD - 5);
        int effectiveMaxNote = min(127, maxD + 5);

        // Ensure we always show at least the B2-A4 range (plus padding)
        effectiveMinNote = min(effectiveMinNote, 42); // 47 - 5
        effectiveMaxNote = max(effectiveMaxNote, 74); // 69 + 5

        // Calculate total width
        double totalWidth = constraints.maxWidth;
        final DateTime now = clock.now();

        double recordingX = 0;
        bool hasRecording = widget.history.isNotEmpty;

        if (hasRecording) {
          final firstPointTime = widget.history.first.time;
          final sessionDuration =
              now.difference(firstPointTime).inMilliseconds / 1000.0;
          recordingX = sessionDuration * pixelsPerSecond;
          totalWidth = max(totalWidth, recordingX + 100);
        }

        if (widget.noteEvents.isNotEmpty) {
          final lastNote = widget.noteEvents.last;
          final endTime = lastNote.startTime + lastNote.duration;
          final analysisWidth = endTime * pixelsPerSecond;
          totalWidth = max(totalWidth, analysisWidth + 100);
        }

        // Auto-scroll logic: Follow the recording playhead
        if (widget.isRecording && hasRecording) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && widget.isRecording) {
              // Keep the playhead at the right edge of the screen
              final targetOffset = max(
                0.0,
                recordingX - (constraints.maxWidth - 50),
              );
              _scrollController.jumpTo(targetOffset);
            }
          });
        }

        return Container(
          color: const Color(0xFF121212), // Deep background
          child: Stack(
            children: [
              // 1. Scrolling Content (Grid and Pitch)
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size(
                                max(totalWidth, constraints.maxWidth),
                                constraints.maxHeight -
                                    30, // Leave space for timeline
                              ),
                              painter: _PitchPainter(
                                history: widget.history,
                                noteEvents: widget.noteEvents,
                                isRecording: widget.isRecording,
                                pixelsPerSecond: pixelsPerSecond,
                                visibleTimeWindow: widget.visibleTimeWindow,
                                minNote: effectiveMinNote,
                                maxNote: effectiveMaxNote,
                                viewportWidth: constraints.maxWidth,
                                now: now,
                                drawLabels: false,
                              ),
                            ),
                            if (widget.showVocalActivity &&
                                widget.history.isNotEmpty)
                              Positioned(
                                left: 0,
                                bottom: 0,
                                width: max(totalWidth, constraints.maxWidth),
                                child: RepaintBoundary(
                                  child: VocalActivityChart(
                                    history: widget.history,
                                    pixelsPerSecond: pixelsPerSecond,
                                    height: 120, // Height of the bar chart
                                    sessionStartTime: widget.history.first.time,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      PitchTimeline(
                        pixelsPerSecond: pixelsPerSecond,
                        totalWidth: max(totalWidth, constraints.maxWidth),
                        scrollOffset:
                            0, // Since it's inside the scrollview, we don't need offset for internal painting
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Fixed Labels Overlay
              Positioned(
                left: 0,
                top: 0,
                bottom: 30, // Align with canvas, leave timeline space
                width: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    border: const Border(
                      right: BorderSide(color: Colors.white10),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _PitchLabelsPainter(
                      minNote: effectiveMinNote,
                      maxNote: effectiveMaxNote,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PitchLabelsPainter extends CustomPainter {
  final int minNote;
  final int maxNote;

  _PitchLabelsPainter({required this.minNote, required this.maxNote});

  @override
  void paint(Canvas canvas, Size size) {
    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;

    for (int i = minNote; i <= maxNote; i++) {
      final y = size.height - ((i - minNote) * heightPerNote);
      final isC = (i % 12) == 0;
      final isAccidental = [1, 3, 6, 8, 10].contains(i % 12);

      if (isC || !isAccidental) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _midiToNoteName(i),
            style: TextStyle(
              color: isC ? Colors.white70 : Colors.white38,
              fontSize: isC ? 10 : 8,
              fontWeight: isC ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
      }
    }
  }

  String _midiToNoteName(int midi) {
    final names = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final octave = (midi / 12).floor() - 1;
    return '${names[midi % 12]}$octave';
  }

  @override
  bool shouldRepaint(covariant _PitchLabelsPainter oldDelegate) =>
      oldDelegate.minNote != minNote || oldDelegate.maxNote != maxNote;
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
  final DateTime now;
  final bool drawLabels;

  _PitchPainter({
    required this.history,
    required this.noteEvents,
    required this.isRecording,
    required this.pixelsPerSecond,
    required this.visibleTimeWindow,
    required this.minNote,
    required this.maxNote,
    required this.viewportWidth,
    required this.now,
    this.drawLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (noteEvents.isNotEmpty) {
      _drawNoteEvents(canvas, size);
    }

    if (history.isNotEmpty) {
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

      if (drawLabels && isC) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'C${(i / 12).floor() - 1}',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
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

    // Add glow effect to the main line
    final shadowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.stroke;

    final bridgePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final bridgePath = Path();
    bool isFirst = true;

    // Calculate session start time for X offset
    final sessionStartTime = history.first.time;

    for (int i = 0; i < history.length; i++) {
      final point = history[i];
      final diffMsFromStart = point.time
          .difference(sessionStartTime)
          .inMilliseconds;
      final x = diffMsFromStart / 1000.0 * pixelsPerSecond;

      final y = PitchCoordinateMapper.calculateY(
        hz: point.hz,
        minNote: minNote,
        maxNote: maxNote,
        height: size.height,
      );

      if (point.clarity < 0.4) {
        // If it's a short gap, we could bridge it.
        // But for simplicity in path drawing, we break the main path here.
        isFirst = true;

        // Short gap bridging: peek next point
        if (i > 0 && i < history.length - 1) {
          final prev = history[i - 1];
          final next = history[i + 1];
          if (prev.clarity >= 0.4 && next.clarity >= 0.4) {
            final gapMs = next.time.difference(prev.time).inMilliseconds;
            if (gapMs < 300) {
              final prevX =
                  prev.time.difference(sessionStartTime).inMilliseconds /
                  1000.0 *
                  pixelsPerSecond;
              final prevY = PitchCoordinateMapper.calculateY(
                hz: prev.hz,
                minNote: minNote,
                maxNote: maxNote,
                height: size.height,
              );
              final nextX =
                  next.time.difference(sessionStartTime).inMilliseconds /
                  1000.0 *
                  pixelsPerSecond;
              final nextY = PitchCoordinateMapper.calculateY(
                hz: next.hz,
                minNote: minNote,
                maxNote: maxNote,
                height: size.height,
              );

              bridgePath.moveTo(prevX, prevY);
              bridgePath.lineTo(nextX, nextY);
            }
          }
        }
        continue;
      }

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw paths
    canvas.drawPath(bridgePath, bridgePaint);
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // 2. Draw Vertical Playhead (Current Time Indicator)
    if (isRecording) {
      final nowDiffMs = now.difference(sessionStartTime).inMilliseconds;
      final playheadX = nowDiffMs / 1000.0 * pixelsPerSecond;

      final playheadPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.4)
        ..strokeWidth = 1.0;

      // Draw playhead vertical line
      canvas.drawLine(
        Offset(playheadX, 0),
        Offset(playheadX, size.height),
        playheadPaint,
      );

      // Draw cursor point (the pulsing head)
      final last = history.last;
      final headX = playheadX; // Use playhead X for the very tip

      if (last.clarity >= 0.4) {
        final headY = PitchCoordinateMapper.calculateY(
          hz: last.hz,
          minNote: minNote,
          maxNote: maxNote,
          height: size.height,
        );

        canvas.drawCircle(
          Offset(headX, headY),
          5,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(headX, headY),
          10,
          Paint()..color = Colors.cyanAccent.withValues(alpha: 0.3),
        );
      } else {
        // If silent, show a small pulsing dot at the bottom to indicate listening
        final pulseSize = 3.0 + (sin(now.millisecondsSinceEpoch / 200) * 2);
        canvas.drawCircle(
          Offset(headX, size.height - 10),
          pulseSize,
          Paint()..color = Colors.cyanAccent.withValues(alpha: 0.2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => true;
}
