# Track Plan: Global Monophonic Enforcement

## Phase 1: Rust Implementation & Testing
- [x] Task: Implement Global Monophony Logic
    - [x] Create `enforce_global_monophony` in `rust/src/api/pitch.rs`.
    - [x] Implement sorting by `start_time`.
    - [x] Implement the overlap resolution loop (Strategy 2: Confidence-based).
- [x] Task: Write Rust Unit Tests (Red Phase)
    - [x] Add tests in `pitch.rs` simulating overlapping notes with different confidence levels.
    - [x] Verify truncation and removal behavior.
- [x] Task: Integrate into Audio Analysis
    - [x] Call `enforce_global_monophony` after `merge_note_events` in `analyze_audio_file`.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Rust Implementation & Testing' (Protocol in workflow.md)

## Phase 2: Integration Verification
- [x] Task: Verify with Integration Tests
    - [x] Run `test/core/audio_analysis_accuracy_test.dart`.
    - [x] Add specific assertion to verify no overlaps exist in the output.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Integration Verification' (Protocol in workflow.md)
