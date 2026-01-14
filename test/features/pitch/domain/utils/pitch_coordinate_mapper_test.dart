// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/domain/utils/pitch_coordinate_mapper.dart';

void main() {
  group('PitchCoordinateMapper', () {
    test('calculateX should be relative to provided now (Wall Clock)', () {
      final now = DateTime(2026, 1, 1, 12, 0, 10);
      final pointTime = DateTime(2026, 1, 1, 12, 0, 0); // 10s ago
      const visibleTimeWindow = 20.0;
      const width = 1000.0;

      // 10s / 20s = 0.5. X should be in the middle (500).
      final x = PitchCoordinateMapper.calculateX(
        pointTime: pointTime,
        now: now,
        visibleTimeWindow: visibleTimeWindow,
        width: width,
      );

      expect(x, equals(500.0));
    });

    test('calculateX should be width if pointTime == now', () {
      final now = DateTime(2026, 1, 1, 12, 0, 0);
      final pointTime = now;
      const visibleTimeWindow = 10.0;
      const width = 1000.0;

      final x = PitchCoordinateMapper.calculateX(
        pointTime: pointTime,
        now: now,
        visibleTimeWindow: visibleTimeWindow,
        width: width,
      );

      expect(x, equals(1000.0));
    });
  });
}
