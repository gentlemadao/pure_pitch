// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(talkerInstance)
final talkerInstanceProvider = TalkerInstanceProvider._();

final class TalkerInstanceProvider
    extends $FunctionalProvider<Talker, Talker, Talker>
    with $Provider<Talker> {
  TalkerInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'talkerInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$talkerInstanceHash();

  @$internal
  @override
  $ProviderElement<Talker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Talker create(Ref ref) {
    return talkerInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Talker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Talker>(value),
    );
  }
}

String _$talkerInstanceHash() => r'263ebe8f145eaf64d024088b68bbd0acfddd4719';
