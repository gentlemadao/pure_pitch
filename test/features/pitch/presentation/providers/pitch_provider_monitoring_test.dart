// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cycleMonitoringVolume should cycle through 0.0, 0.4, 0.7', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(pitchProvider.notifier);

    // Initial: 0.0
    expect(container.read(pitchProvider).monitoringVolume, equals(0.0));

    // Cycle to 0.4
    notifier.cycleMonitoringVolume();
    expect(container.read(pitchProvider).monitoringVolume, equals(0.4));

    // Cycle to 0.7
    notifier.cycleMonitoringVolume();
    expect(container.read(pitchProvider).monitoringVolume, equals(0.7));

    // Cycle back to 0.0
    notifier.cycleMonitoringVolume();
    expect(container.read(pitchProvider).monitoringVolume, equals(0.0));
  });

  test('toggleAccompaniment should update state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(pitchProvider.notifier);

    expect(container.read(pitchProvider).isAccompanimentEnabled, false);

    notifier.toggleAccompaniment(true);
    expect(container.read(pitchProvider).isAccompanimentEnabled, true);
  });
}
