# Flutter Style Guide

## UI Components
*   **Widgets**: Prefer `ConsumerWidget` or `ConsumerStatefulWidget`.
*   **Constructors**: Use `const` constructors wherever possible.
*   **Build Method**: Keep under 100 lines. Extract complex logic to `presentation/widgets/`.
*   **Internationalization**: MANDATORY use of `context.l10n` for all strings. No hardcoded text.

## Routing (GoRouter)
*   **Configuration**: located in `core/router/`.
*   **Type Safety**: Use `go_router_builder`.
*   **Navigation**: Use `ContextExtension` for advanced pops (e.g., `popUntilPath`).

## Theme & Assets
*   **Colors/Icons**: Use `AppColors` and `AppIcons`. No hardcoded hex values.
*   **Feedback**: Always show loading states for async ops. Use `AppToast` for errors.
