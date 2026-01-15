# Track Spec: Full Application Internationalization (i18n)

## Overview
This track involves extracting all hard-coded strings from the application and moving them to `intl_utils` based ARB files for multi-language support. English (en) and Chinese (zh) will be the initial supported languages.

## Functional Requirements
- **String Extraction**: Identify and extract all user-facing strings (UI labels, error messages, tooltips, dialogs) into `lib/core/localization/l10n/intl_en.arb` and `lib/core/localization/l10n/intl_zh.arb`.
- **Intl Integration**: Replace all hard-coded strings in the codebase with calls to `S.of(context).key` or `S.current.key` (for non-contextual areas like providers).
- **Language Switcher**:
    - Add a "Settings" section to the Navigation Drawer.
    - Implement a language selection dialog or page allowing users to toggle between English and Chinese.
- **Persistence**: Save the selected language preference locally using `shared_preferences` (via `StorageService`).

## Technical Strategy
- **Library**: `intl_utils` (already in `pubspec.yaml`).
- **Generation**: Run `flutter pub run intl_utils:generate` to update the `S` class.
- **Provider**: Use a Riverpod `StateProvider` or `Notifier` to manage and persist the current `Locale`.

## Acceptance Criteria
- [ ] All UI elements display correctly in both English and Chinese.
- [ ] Language selection persists across application restarts.
- [ ] No hard-coded user-facing strings remain in the `lib/` directory.
- [ ] Error messages and logs (where user-facing) are correctly localized.

## Out of Scope
- Automatic translation (manual entry in ARB files is required).
- Support for right-to-left (RTL) languages in this track.
