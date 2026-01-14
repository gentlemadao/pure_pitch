// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';

class PitchTimeline extends StatelessWidget {
  final double pixelsPerSecond;
  final double totalWidth;
  final double scrollOffset;

  const PitchTimeline({
    super.key,
    required this.pixelsPerSecond,
    required this.totalWidth,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: totalWidth,
      height: 30,
      child: CustomPaint(
        painter: _TimelinePainter(
          pixelsPerSecond: pixelsPerSecond,
          scrollOffset: scrollOffset,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final double pixelsPerSecond;
  final double scrollOffset;

  _TimelinePainter({
    required this.pixelsPerSecond,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    const double tickHeight = 5.0;
    const double majorTickHeight = 10.0;

    // We only need to draw what's visible. 
    // pixelsPerSecond is correct. size.width is totalWidth.
    
    final double durationSeconds = size.width / pixelsPerSecond;

    for (int i = 0; i <= durationSeconds.ceil(); i++) {
      final x = i * pixelsPerSecond;
      
      // Draw major tick every second
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, majorTickHeight),
        paint,
      );

      // Draw sub-ticks (0.5s)
      final midX = x + (pixelsPerSecond / 2);
      if (midX < size.width) {
         canvas.drawLine(
           Offset(midX, 0),
           Offset(midX, tickHeight),
           paint,
         );
      }

      // Draw label every 5 seconds
      if (i % 5 == 0) {
        final minutes = i ~/ 60;
        final seconds = i % 60;
        final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), majorTickHeight + 2));
      }
    }
    
    // Draw top border
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      oldDelegate.pixelsPerSecond != pixelsPerSecond ||
      oldDelegate.scrollOffset != scrollOffset;
}
