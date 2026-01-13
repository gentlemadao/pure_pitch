// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'dart:io';

void main() {
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

  test(
    'visibleTimeWindow defaults to 5.0 and can be updated with clamping',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(pitchProvider);
      // Expect error here because visibleTimeWindow is not yet in PitchState
      expect(state.visibleTimeWindow, 5.0);

      final notifier = container.read(pitchProvider.notifier);

      notifier.updateVisibleTimeWindow(7.5);
      expect(container.read(pitchProvider).visibleTimeWindow, 7.5);

      notifier.updateVisibleTimeWindow(4.0); // Below min
      expect(container.read(pitchProvider).visibleTimeWindow, 5.0);

      notifier.updateVisibleTimeWindow(12.0); // Above max
      expect(container.read(pitchProvider).visibleTimeWindow, 10.0);
    },
  );

  test('scaling logic calculation', () {
    double calculate(double width) {
      if (width < 600) return 5.0;
      if (width > 1200) return 10.0;
      return 5.0 + (width - 600) / 600 * 5.0;
    }

    expect(calculate(300), 5.0);
    expect(calculate(600), 5.0);
    expect(calculate(900), 7.5);
    expect(calculate(1200), 10.0);
    expect(calculate(1500), 10.0);
  });
}
