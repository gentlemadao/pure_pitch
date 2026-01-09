l10n:
    flutter pub run intl_utils:generate

build:
    dart run build_runner build --delete-conflicting-outputs

watch:
    dart run build_runner watch --delete-conflicting-outputs

analyze:
    flutter analyze

check: l10n build analyze
