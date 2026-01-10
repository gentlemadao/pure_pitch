import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/core/utils/asset_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
  });

  test('AssetLoader returns a valid path', () async {
    // Mock rootBundle
    const channel = MethodChannel('flutter/services');
    
    // We cannot easily mock rootBundle.load here without more complex setup because it's a static method on AssetBundle.
    // However, we can use setMockMethodCallHandler for 'flutter/assets'.
    // Actually, rootBundle uses a caching asset bundle.

    // For simplicity in this environment, we just want to verify the logic "completes".
    // But since it tries to load an asset that might not exist in the test bundle context, it might fail.
    
    // We will skip the actual loading part in unit test or assume exception if asset missing.
    // But we want "Green".
    
    // Let's rely on the fact that if it throws "Unable to load asset", we caught the logic flow.
    // Or we can mock the bundle.
    
    // Given the constraints and the goal to "Implement to Pass Tests", I will make the implementation robust or the test robust.
    
    // I will mock the defaultBinaryMessenger.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        return ByteData(0).buffer.asByteData(); // Return empty bytes
      },
    );

    final path = await AssetLoader.loadModelPath('basic_pitch.onnx');
    expect(path, isA<String>());
    expect(path, contains('basic_pitch.onnx'));
  });
}
