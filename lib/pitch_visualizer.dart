import 'dart:math';
import 'package:flutter/material.dart';

/// A wrapper to associate a timestamp with the pitch data
class TimestampedPitch {
  final DateTime time;
  final double hz;
  final int midiNote;
  final double clarity;

  TimestampedPitch(this.time, {required this.hz, required this.midiNote, required this.clarity});
}

class PitchVisualizer extends StatelessWidget {
  final List<TimestampedPitch> history;
  final double timeWindowSeconds;
  final int minNote;
  final int maxNote;

  const PitchVisualizer({
    super.key,
    required this.history,
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
  final double timeWindowSeconds;
  final int minNote;
  final int maxNote;

  _PitchPainter({
    required this.history,
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

    // To smooth the line, we can just draw connected segments for now.
    // Real karaoke apps often use splines or just dense points.
    
    // Filter points within the window
    final visiblePoints = history.where((p) => p.time.isAfter(startTime)).toList();

    for (var i = 0; i < visiblePoints.length; i++) {
      final point = visiblePoints[i];
      
      // Map time to X
      final timeOffset = point.time.difference(startTime).inMilliseconds;
      final x = timeOffset * widthPerMs;

      // Map pitch to Y (continuous if possible, but we have midiNote as int. 
      // Ideally we'd use Hz for smooth curve, but let's use MIDI for stable "grid" alignment first.
      // Better: Use Hz to calculate fractional MIDI note for smoothness!)
      
      double fractionalMidi = point.midiNote.toDouble();
      if (point.hz > 0) {
        // midi = 69 + 12 * log2(freq / 440)
        fractionalMidi = 69 + 12 * (log(point.hz / 440.0) / log(2));
      }

      final y = size.height - ((fractionalMidi - minNote) * heightPerNote);

      // Skip invalid points or very low clarity (optional, logic handles distinct events)
      if (point.clarity < 0.3) {
        isFirst = true; // Break the line
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

    // Draw current pitch indicator (circle at the end)
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
         
         // Glow effect
         canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.cyanAccent.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
         canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
       }
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
