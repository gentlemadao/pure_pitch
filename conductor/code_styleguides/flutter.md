# Flutter Style Guide

## UI Components
*   **Widgets**: Prefer `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Constructors**: Use `const` constructors wherever possible.
*   **Build Method**: Keep under 100 lines. Extract complex logic to `presentation/widgets/`.

## Internationalization (i18n)
*   **Library**: Use `intl_utils` for ARB file generation.
*   **Workflow**: 
    1. Define keys in `lib/core/localization/l10n/intl_en.arb`.
    2. Run `dart run intl_utils:generate`.
    3. Access via `context.l10n` (preferred) or `S.current` (if no context).
*   **Rule**: ABSOLUTELY NO hardcoded strings in UI widgets.

## Routing (GoRouter)
*   **Configuration**: located in `core/router/`.
*   **Type Safety**: Use `go_router_builder`.
*   **Navigation**: Use `ContextExtension` for advanced pops (e.g., `popUntilPath`).

## Theme & Assets
*   **Colors/Icons**: Use `AppColors` and `AppIcons`. No hardcoded hex values.
*   **Feedback**: Always show loading states for async ops. Use `AppToast` for errors.
