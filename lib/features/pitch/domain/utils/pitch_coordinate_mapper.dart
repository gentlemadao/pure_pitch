// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:math';

class PitchCoordinateMapper {
  /// Calculates the X coordinate of a pitch point relative to 'now'.
  static double calculateX({
    required DateTime pointTime,
    required DateTime now,
    required double visibleTimeWindow,
    required double width,
  }) {
    final diffMs = now.difference(pointTime).inMilliseconds;
    final pixelsPerSecond = width / visibleTimeWindow;
    return width - (diffMs / 1000.0 * pixelsPerSecond);
  }

  /// Calculates the Y coordinate of a frequency (Hz).
  static double calculateY({
    required double hz,
    required int minNote,
    required int maxNote,
    required double height,
  }) {
    if (hz <= 0) return height;

    final noteRange = maxNote - minNote;
    final heightPerNote = height / noteRange;

    final fractionalMidi = 69 + 12 * (log(hz / 440.0) / log(2));
    return height - ((fractionalMidi - minNote) * heightPerNote);
  }
}
