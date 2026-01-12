# Track Plan: Audio Test Data Generation & Accuracy Validation

## Phase 1: Audio Synthesis Utilities
- [x] Task: Implement Core Synthesis Logic
    - [x] Create a Rust-based or Dart-based utility for generating raw PCM data (Sine, Saw, Square).
    - [x] Implement support for MIDI-to-Frequency conversion.
    - [x] Implement a "Note Sequence" builder that can handle overlapping notes (polyphony).
- [x] Task: WAV File Export Utility
    - [x] Implement a helper to wrap PCM data into a valid WAV file format.
    - [x] Verify generated files can be played/opened by standard tools.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Audio Synthesis Utilities' (Protocol in workflow.md)

## Phase 2: Integration Test Suite
- [x] Task: Setup Integration Test Environment
    - [x] Create `test/core/audio_analysis_accuracy_test.dart`.
    - [x] Ensure the test environment has access to the Basic Pitch model asset.
- [x] Task: Implement Monophonic Accuracy Tests (Red Phase)
    - [x] Write tests for single sine waves at varying frequencies.
    - [x] Write tests for monophonic scales (C Major).
    - [x] Implement "Green Phase" by connecting the generator to `analyzeAudioFile`.
- [x] Task: Implement Polyphonic Accuracy Tests (Red Phase)
    - [x] Write tests for chords (Major/Minor triads).
    - [x] Verify Basic Pitch correctly identifies simultaneous notes.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Integration Test Suite' (Protocol in workflow.md)

## Phase 3: Benchmarking & Reporting
- [x] Task: Accuracy Metric Calculation
    - [x] Implement logic to calculate Jaccard Similarity or F1-score for note detection.
    - [x] Implement timing offset analysis (jitter).
- [x] Task: Final Validation & Baseline
    - [x] Run the full suite against the current model.
    - [x] Document the baseline accuracy in a markdown report.
- [x] Task: Conductor - User Manual Verification 'Phase 3: Benchmarking & Reporting' (Protocol in workflow.md)
