// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/domain/utils/pitch_smoother.dart';

void main() {
  group('PitchSmoother', () {
    test('should reject extreme outliers (Vocal Range Gating)', () {
      final smoother = PitchSmoother(maxMidiNote: 96); // C7

      // Valid note
      expect(smoother.smooth(440.0, 69).hz, equals(440.0));

      // Outlier (A8 = 117) should be rejected/returned as 0 or last stable
      final result = smoother.smooth(7040.0, 117);
      expect(
        result.hz,
        equals(440.0),
        reason: 'Extreme spike should be rejected',
      );
    });

    test('should smooth jitter using EMA', () {
      final smoother = PitchSmoother(emaAlpha: 0.5);

      // Initial value
      smoother.smooth(400.0, 60);

      // Next raw value is 500. Result should be 0.5 * 500 + 0.5 * 400 = 450.
      final result = smoother.smooth(500.0, 60);
      expect(result.hz, equals(450.0));
    });

    test('should use median filtering for short-term stability', () {
      final smoother = PitchSmoother(medianWindowSize: 3);

      // Sequence: 400, 1000 (spike), 400
      smoother.smooth(400.0, 60);
      final spikeResult = smoother.smooth(1000.0, 110);
      final backResult = smoother.smooth(400.0, 60);

      // With median filter of 3, the '1000' should be largely ignored or dampened
      expect(spikeResult.hz, lessThan(600.0));
      expect(backResult.hz, equals(400.0));
    });

    test('smoothBatch should remove short spikes in a sequence', () {
      final data = [440.0, 440.0, 1000.0, 440.0, 440.0];
      final refined = PitchSmoother.smoothBatch(data, window: 3);

      expect(
        refined[2],
        equals(440.0),
        reason: 'Spike should be replaced by median',
      );
    });

    test('should dampen noisy input data', () {
      final smoother = PitchSmoother(
        emaAlpha: 0.1,
      ); // Low alpha for high smoothing

      // Generate a steady note with noise
      // Target: 440Hz. Noise: +/- 50Hz
      // We expect the smoothed output to be closer to 440 than the raw noise.

      final noisyInput = [
        440.0,
        490.0,
        390.0,
        440.0,
        460.0,
        420.0,
        440.0,
        1000.0,
        440.0, // 1000 is a spike
      ];

      final smoothedOutput = <double>[];

      for (final hz in noisyInput) {
        smoothedOutput.add(smoother.smooth(hz, PitchSmoother.hzToMidi(hz)).hz);
      }

      // The 8th element (index 7) is 1000.0 input.
      // With median filter (default 3) and EMA 0.1, it should be significantly lower.
      // The median of [440, 1000, 440] is 440. So the spike is effectively rejected before EMA.
      expect(
        smoothedOutput[7],
        closeTo(440.0, 50.0),
        reason: 'Spike should be rejected by median filter',
      );

      // The general flow should stay around 440
      expect(smoothedOutput.last, closeTo(440.0, 20.0));
    });
  });
}
