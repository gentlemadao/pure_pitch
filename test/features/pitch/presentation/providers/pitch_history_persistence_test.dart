// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/features/pitch/domain/services/pitch_detector_service.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clock/clock.dart';
import 'dart:typed_data';

class MockPitchDetectorService extends Mock implements PitchDetectorService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Float32List(0));
  });

  test('history should persist all data during session (no 6s cutoff)', () async {
    final mockService = MockPitchDetectorService();

    when(() => mockService.detectLive(
          samples: any(named: 'samples'),
          sampleRate: any(named: 'sampleRate'),
        )).thenAnswer((_) async => const LivePitch(
          hz: 440.0,
          midiNote: 69,
          clarity: 0.9,
        ));

    final container = ProviderContainer(
      overrides: [
        pitchDetectorServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(pitchProvider.notifier);
    final dummySamples = Float32List(512);

    final startTime = DateTime(2026, 1, 1, 12, 0, 0);

    await withClock(Clock.fixed(startTime), () async {
      // 1. Add data at t=0
      await notifier.analyze(dummySamples);
      expect(container.read(pitchProvider).history.length, 1);
    });

    final laterTime = startTime.add(const Duration(seconds: 10));
    await withClock(Clock.fixed(laterTime), () async {
      // 2. Add data at t=10
      await notifier.analyze(dummySamples);

      // 3. Verify persistence
      final history = container.read(pitchProvider).history;
      expect(history.length, 2,
          reason: 'History should keep data beyond 6 seconds');
    });
  });
}