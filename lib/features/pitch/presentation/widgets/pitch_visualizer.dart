import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';

class PitchVisualizer extends StatelessWidget {
  final List<TimestampedPitch> history;
  final List<NoteEvent> noteEvents;
  final double timeWindowSeconds;
  final int minNote;
  final int maxNote;

  const PitchVisualizer({
    super.key,
    required this.history,
    this.noteEvents = const [],
    this.timeWindowSeconds = 5.0,
    this.minNote = 36, // C2
    this.maxNote = 84, // C6
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        color: const Color(0xFF1E1E1E), // Dark background like typical DAW/Karaoke
        child: CustomPaint(
          painter: _PitchPainter(
            history: history,
            noteEvents: noteEvents,
            timeWindowSeconds: timeWindowSeconds,
            minNote: minNote,
            maxNote: maxNote,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final List<TimestampedPitch> history;
  final List<NoteEvent> noteEvents;
  final double timeWindowSeconds;
  final int minNote;
  final int maxNote;

  _PitchPainter({
    required this.history,
    required this.noteEvents,
    required this.timeWindowSeconds,
    required this.minNote,
    required this.maxNote,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final windowDuration = Duration(milliseconds: (timeWindowSeconds * 1000).toInt());
    final startTime = now.subtract(windowDuration);

    _drawGrid(canvas, size);
    _drawNoteEvents(canvas, size); // Draw offline notes first (layering)
    _drawPitchCurve(canvas, size, startTime, now);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;

    for (int i = minNote; i <= maxNote; i++) {
      // Draw line for every C note (octave)
      final isC = (i % 12) == 0;
      if (isC) {
        paint.color = Colors.white.withValues(alpha: 0.2);
        paint.strokeWidth = 1.0;
      } else {
        paint.color = Colors.white.withValues(alpha: 0.05);
        paint.strokeWidth = 0.5;
      }

      final y = size.height - ((i - minNote) * heightPerNote);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      if (isC) {
        textPainter.text = TextSpan(
          text: 'C${(i / 12).floor() - 1}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
      }
    }
  }

  void _drawNoteEvents(Canvas canvas, Size size) {
    if (noteEvents.isEmpty) return;

    final paint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final noteRange = maxNote - minNote;
    final heightPerNote = size.height / noteRange;
    
    // For offline analysis, we visualize the whole file. 
    // But PitchVisualizer is currently time-windowed for real-time.
    // If we want to show offline results, we probably need a different mode or map time differently.
    // Assuming for now we show them if they fall into the window? 
    // Or if this is purely offline viewer, we might want to scroll.
    // Given the task is "Update PitchVisualizer to render NoteEvents", let's assume we map them to the same scale.
    // But NoteEvents are absolute time from start of file (0.0).
    // Real-time history is DateTime.
    // This implies we need a way to align them.
    // If we are "playing" the file, we have a current play time.
    // For this MVP step, let's just render them relative to 0.0 -> Total Duration, 
    // BUT PitchVisualizer is `startTime` to `now`.
    // This suggests PitchVisualizer needs to know if we are in "Real-time" or "Playback" mode.
    
    // For simplicity, let's just draw them if they fit in the view assuming "now" corresponds to some playback head?
    // Since we don't have playback yet, let's just map them to the full width if we pass a different time window?
    // Or just simple visualization: Scale total duration to width?
    
    // Let's implement a simple "Fit to Screen" logic if history is empty?
    // Or just iterate and draw.
    
    // We will assume 1 pixel = X seconds? No, widthPerMs.
    // If we are in offline mode, `history` might be empty?
    
    // Let's assume we map NoteEvents relative to the start of the visualization window.
    // But we don't have "start of visualization window" for file viewing yet.
    
    // Simplification: Just draw them assuming X axis is 0 to max(note.end).
    
    double maxTime = 0;
    if (noteEvents.isNotEmpty) {
      maxTime = noteEvents.last.startTime + noteEvents.last.duration;
    }
    if (maxTime == 0) return;

    final widthPerSec = size.width / maxTime;

    for (final note in noteEvents) {
      final x = note.startTime * widthPerSec;
      final w = note.duration * widthPerSec;
      final y = size.height - ((note.midiNote - minNote) * heightPerNote);
      
      canvas.drawRect(Rect.fromLTWH(x, y, w, heightPerNote), paint);
    }
  }

  void _drawPitchCurve(Canvas canvas, Size size, DateTime startTime, DateTime endTime) {
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
    final widthPerMs = size.width / (endTime.difference(startTime).inMilliseconds);

    final visiblePoints = history.where((p) => p.time.isAfter(startTime)).toList();

    for (var i = 0; i < visiblePoints.length; i++) {
      final point = visiblePoints[i];
      
      final timeOffset = point.time.difference(startTime).inMilliseconds;
      final x = timeOffset * widthPerMs;
      
      double fractionalMidi = point.midiNote.toDouble();
      if (point.hz > 0) {
        fractionalMidi = 69 + 12 * (log(point.hz / 440.0) / log(2));
      }

      final y = size.height - ((fractionalMidi - minNote) * heightPerNote);

      if (point.clarity < 0.3) {
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

    if (visiblePoints.isNotEmpty) {
       final last = visiblePoints.last;
       if (last.clarity >= 0.3) {
         final timeOffset = last.time.difference(startTime).inMilliseconds;
         final x = timeOffset * widthPerMs;
         
         double fractionalMidi = last.midiNote.toDouble();
         if (last.hz > 0) {
            fractionalMidi = 69 + 12 * (log(last.hz / 440.0) / log(2));
         }
         final y = size.height - ((fractionalMidi - minNote) * heightPerNote);
         
         canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.cyanAccent.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
         canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
       }
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return true;
  }
}