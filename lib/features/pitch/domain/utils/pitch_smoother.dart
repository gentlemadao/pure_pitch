// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:math';

class SmoothedPitch {
  final double hz;
  final int midiNote;

  const SmoothedPitch(this.hz, this.midiNote);
}

class PitchSmoother {
  final int maxMidiNote;
  final double emaAlpha;
  final int medianWindowSize;
  final int maxSemitoneJump;

  final List<double> _history = [];
  double? _lastValidHz;
  int? _lastValidMidi;

  PitchSmoother({
    this.maxMidiNote = 96, // C7
    this.emaAlpha = 0.6, // Increased from 0.3 for better responsiveness
    this.medianWindowSize = 3,
    this.maxSemitoneJump = 12,
  });

  SmoothedPitch smooth(double rawHz, int rawMidi) {
    // 1. Vocal Range Gating (Loose)
    if (rawMidi > 110 || rawMidi <= 0) {
      return SmoothedPitch(_lastValidHz ?? 0, _lastValidMidi ?? 0);
    }

    // 2. Relative Jump Filtering (Physical limits)
    // Only filter if the jump is extreme (e.g. > 1 octave)
    if (_lastValidMidi != null && _lastValidHz != null && _lastValidHz! > 0) {
      final jump = (rawMidi - _lastValidMidi!).abs();
      if (jump > maxSemitoneJump) {
        return SmoothedPitch(_lastValidHz!, _lastValidMidi!);
      }
    }

    // 3. Median Filtering (Smallest window to avoid flattening)
    _history.add(rawHz);
    if (_history.length > medianWindowSize) {
      _history.removeAt(0);
    }

    final sorted = List<double>.from(_history)..sort();
    final medianHz = sorted[sorted.length ~/ 2];

    // 4. EMA Smoothing (Higher alpha = less lag)
    final double resultHz;
    if (_lastValidHz == null || _lastValidHz == 0) {
      resultHz = medianHz;
    } else {
      resultHz = (emaAlpha * medianHz) + ((1.0 - emaAlpha) * _lastValidHz!);
    }

    // Update state
    _lastValidHz = resultHz;
    _lastValidMidi = hzToMidi(resultHz);

    return SmoothedPitch(_lastValidHz!, _lastValidMidi!);
  }

  /// Performs a high-quality refinement on a segment of data.
  static List<double> smoothBatch(List<double> segment, {int window = 5}) {
    if (segment.length < window) return segment;

    final results = List<double>.from(segment);
    for (int i = 0; i < segment.length; i++) {
      final start = max(0, i - window ~/ 2);
      final end = min(segment.length, i + window ~/ 2 + 1);
      final sub = segment.sublist(start, end);
      final sorted = List<double>.from(sub)..sort();
      final median = sorted[sorted.length ~/ 2];

      // Smart refinement: Only replace if the distance to median is large (outlier)
      // If it's close to the median, keep the original to preserve detail.
      final current = segment[i];
      if (current > 0 && median > 0) {
        final diffSemitones = (12 * (log(current / median) / log(2))).abs();
        if (diffSemitones > 1.0) {
          // If more than 1 semitone away from median
          results[i] = median;
        } else {
          results[i] = current;
        }
      } else {
        results[i] = median;
      }
    }
    return results;
  }

  static int hzToMidi(double hz) {
    if (hz <= 0) return 0;
    return (69 + 12 * (log(hz / 440.0) / log(2))).round();
  }
}
