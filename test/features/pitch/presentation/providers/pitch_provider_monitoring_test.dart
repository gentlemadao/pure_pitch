// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!RustLib.instance.initialized) {
      final String dylibPath;
      if (Platform.isMacOS) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.dylib';
      } else if (Platform.isWindows) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/rust_lib_pure_pitch.dll';
      } else {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.so';
      }
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    }
  });

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
