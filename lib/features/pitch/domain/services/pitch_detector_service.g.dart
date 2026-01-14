// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_detector_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pitchDetectorService)
final pitchDetectorServiceProvider = PitchDetectorServiceProvider._();

final class PitchDetectorServiceProvider
    extends
        $FunctionalProvider<
          PitchDetectorService,
          PitchDetectorService,
          PitchDetectorService
        >
    with $Provider<PitchDetectorService> {
  PitchDetectorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pitchDetectorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pitchDetectorServiceHash();

  @$internal
  @override
  $ProviderElement<PitchDetectorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PitchDetectorService create(Ref ref) {
    return pitchDetectorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PitchDetectorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PitchDetectorService>(value),
    );
  }
}

String _$pitchDetectorServiceHash() =>
    r'07f505456192c01d5ecca4e1efcd455753040755';
