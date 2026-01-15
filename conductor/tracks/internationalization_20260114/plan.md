# Track Plan: Full Application Internationalization (i18n)

## Phase 1: ARB Setup & String Extraction
- [x] Task: Audit codebase and extract all strings to `intl_en.arb`
- [x] Task: Create `intl_zh.arb` and provide translations for all keys
- [x] Task: Generate `S` class using `flutter pub run intl_utils:generate`
- [ ] Task: Conductor - User Manual Verification 'Phase 1: ARB Setup & String Extraction' (Protocol in workflow.md)

## Phase 2: Global Code Refactor (Replacing Strings)
- [x] Task: Refactor `presentation` layer widgets to use `S.of(context)`
- [x] Task: Refactor `providers` and `repositories` to use `S.current` for error messages
- [x] Task: Verify that all dialogs and snackbars are localized
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Global Code Refactor' (Protocol in workflow.md)

## Phase 3: Language Switching & Persistence
- [x] Task: Implement `LocaleNotifier` using Riverpod to manage application `Locale`
- [x] Task: Implement persistence for `Locale` using `StorageService`
- [x] Task: Add Language Switcher UI in the Navigation Drawer
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Language Switching & Persistence' (Protocol in workflow.md)
