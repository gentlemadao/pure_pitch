// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:just_audio/just_audio.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  test('toggleMonitoring should update state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    
    final notifier = container.read(pitchProvider.notifier);
    
    expect(container.read(pitchProvider).isMonitoringEnabled, false);
    
    notifier.toggleMonitoring(true);
    expect(container.read(pitchProvider).isMonitoringEnabled, true);
  });

  // More complex tests for sync will require mocking the internal AudioPlayer 
  // which might need a service wrapper.
}
