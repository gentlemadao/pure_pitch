# Dart Style Guide

## General
*   **Formatting**: Adhere to `dart format`.
*   **Linting**: Strictly follow `flutter_lints`.
*   **Naming**:
    *   Classes: `PascalCase`
    *   Variables/Functions: `camelCase`
    *   Files: `snake_case.dart`
*   **Async**: Return `FutureOr<T>` or `Stream<T>` for async providers.

## State Management (Riverpod)
*   **Generator**: Use `riverpod_generator` exclusively.
*   **Providers**:
    *   Read-only: Functional providers.
    *   Stateful: Class-based Notifiers.
*   **Ref**: Use `Ref` type, not generated specific refs.

## Data Models (Freezed)
*   **Immutability**: Use `@freezed` annotation.
*   **Structure**: MANDATORY `abstract class` for entities, `sealed class` for unions.
*   **Serialization**: Use `@JsonSerializable`.
