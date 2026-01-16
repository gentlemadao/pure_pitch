// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppLocale)
final appLocaleProvider = AppLocaleProvider._();

final class AppLocaleProvider extends $NotifierProvider<AppLocale, ui.Locale> {
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  AppLocale create() => AppLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ui.Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ui.Locale>(value),
    );
  }
}

String _$appLocaleHash() => r'140b794a6ef54139f0ec296846ff3a507852c05a';

abstract class _$AppLocale extends $Notifier<ui.Locale> {
  ui.Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ui.Locale, ui.Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ui.Locale, ui.Locale>,
              ui.Locale,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
