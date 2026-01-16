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

# Build the Rust library
rust-build:
    cd rust && cargo build

# Run Rust unit tests
rust-test:
    cd rust && cargo test

# Check Dart code formatting (fails if formatting is needed)
format-check:
    dart format --output=none --set-exit-if-changed lib test integration_test packages

# Format all Dart code
format:
    dart format lib test integration_test packages

# Download external dynamic libraries (ONNX Runtime)
setup-libs:
    ./scripts/download_libs.sh

# Perform a full check: localization, code generation, formatting, analysis, and tests
check: l10n build format-check analyze rust-test