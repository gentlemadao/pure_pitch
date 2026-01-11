# Generate internationalization (i18n) code from ARB files
l10n:
    flutter pub run intl_utils:generate

# Generate the Rust-Dart bridge glue code and run Flutter build_runner
build: rust-gen
    dart run build_runner build --delete-conflicting-outputs

# Run build_runner in watch mode for automatic code regeneration
watch:
    dart run build_runner watch --delete-conflicting-outputs

# Run static analysis to check for errors and linting issues
analyze:
    flutter analyze

# Generate the low-level bridge code using flutter_rust_bridge_codegen
rust-gen:
    flutter_rust_bridge_codegen generate

# Compile the Rust core library
rust-build:
    cd rust && cargo build

# Execute all unit tests in the Rust core library
rust-test:
    cd rust && cargo test

# Execute a comprehensive project check (l10n, build, analyze, and rust-test)
check: l10n build analyze rust-test
