import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        return ByteData(0).buffer.asByteData();
      },
    );
  });

  test('analyzePath sets state to analyzing then error (on bad path)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(pitchProvider.notifier);
    
    // Initial state
    expect(container.read(pitchProvider).isAnalyzing, false);

    final states = <bool>[];
    container.listen(pitchProvider.select((s) => s.isAnalyzing), (previous, next) {
      states.add(next);
    });

    // Trigger analysis with bad path
    final future = notifier.analyzePath('bad/path.wav');
    
    await future;

    // Expect states: [true, false]
    expect(states, [true, false]);
    expect(container.read(pitchProvider).errorMessage, isNotNull);
  });
}