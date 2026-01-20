// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';

class VocalActivityChart extends StatelessWidget {
  final List<TimestampedPitch> history;
  final double pixelsPerSecond;
  final double height;
  final DateTime sessionStartTime;

  const VocalActivityChart({
    super.key,
    required this.history,
    required this.pixelsPerSecond,
    required this.height,
    required this.sessionStartTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: VocalActivityPainter(
          history: history,
          pixelsPerSecond: pixelsPerSecond,
          sessionStartTime: sessionStartTime,
        ),
      ),
    );
  }
}

class VocalActivityPainter extends CustomPainter {
  final List<TimestampedPitch> history;
  final double pixelsPerSecond;
  final DateTime sessionStartTime;

  VocalActivityPainter({
    required this.history,
    required this.pixelsPerSecond,
    required this.sessionStartTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final greenPaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final grayPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Add glow effect for green parts
    final glowPaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..style = PaintingStyle.fill;

    const barWidth = 2.0;

    for (final point in history) {
      final diffMs = point.time.difference(sessionStartTime).inMilliseconds;
      final x = (diffMs / 1000.0) * pixelsPerSecond;

      // Normalize amplitude for display
      // Amplitude is RMS, usually small. Let's scale it.
      // Assuming 0.0 to 1.0 range, but practically most vocal signals are < 0.5 RMS.
      final totalHeight = (point.amplitude * size.height * 2.0).clamp(
        0.0,
        size.height,
      );

      if (totalHeight <= 0) continue;

      final greenHeight = totalHeight * point.clarity;
      final grayHeight = totalHeight - greenHeight;

      // Draw Gray portion (top part of the bar if we stack from bottom)
      // Actually "Stacked" usually means one on top of another.
      // Let's draw Green at bottom, Gray on top of it.

      // Gray Rect
      final grayRect = Rect.fromLTWH(
        x - barWidth / 2,
        size.height - totalHeight,
        barWidth,
        grayHeight,
      );
      canvas.drawRect(grayRect, grayPaint);

      // Green Rect
      final greenRect = Rect.fromLTWH(
        x - barWidth / 2,
        size.height - greenHeight,
        barWidth,
        greenHeight,
      );

      if (point.clarity > 0.4) {
        canvas.drawRect(greenRect.inflate(1), glowPaint);
      }
      canvas.drawRect(greenRect, greenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant VocalActivityPainter oldDelegate) => true;
}
