// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Pitch)
final pitchProvider = PitchProvider._();

final class PitchProvider extends $NotifierProvider<Pitch, PitchState> {
  PitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pitchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pitchHash();

  @$internal
  @override
  Pitch create() => Pitch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PitchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PitchState>(value),
    );
  }
}

String _$pitchHash() => r'1b8d7f68c06488553b1df751d0a51e82dbf4fc0a';

abstract class _$Pitch extends $Notifier<PitchState> {
  PitchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PitchState, PitchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PitchState, PitchState>,
              PitchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
