import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

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

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          return ByteData(0).buffer.asByteData();
        });
  });

  test(
    'analyzePath sets state to analyzing then error (on bad path)',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pitchProvider.notifier);

      // Initial state
      expect(container.read(pitchProvider).isAnalyzing, false);

      final states = <bool>[];
      container.listen(pitchProvider.select((s) => s.isAnalyzing), (
        previous,
        next,
      ) {
        states.add(next);
      });

      // Trigger analysis with bad path
      final future = notifier.analyzePath('bad/path.wav');

      await future;

      // Expect states: [true, false]
      expect(states, [true, false]);
      expect(container.read(pitchProvider).errorMessage, isNotNull);
    },
  );
}
