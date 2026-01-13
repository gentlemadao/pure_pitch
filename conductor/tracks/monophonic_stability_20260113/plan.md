# Track Plan: Monophonic Stability with Hysteresis

## Phase 1: Rust Implementation & Testing [checkpoint: 2e8c93d]
- [x] Task: Implement Note Inertia Logic (2e8c93d)
    - [x] Refactor `extract_notes` in `rust/src/api/basic_pitch_postproc.rs` to introduce a "continuation threshold".
    - [x] Implement the logic to favor the currently active note if its probability is still reasonably high.
- [x] Task: Write Rust Unit Tests (Red Phase) (2e8c93d)
    - [x] Add a test case simulating a sustained note with fluctuating probabilities, asserting it is not broken.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Rust Implementation & Testing' (Protocol in workflow.md)

## Phase 2: Integration Verification [checkpoint: 2e8c93d]
- [x] Task: Verify with `chord_c_major.wav` (2e8c93d)
    - [x] Run the analysis on `chord_c_major.wav`.
    - [x] Confirm that the output is a single, continuous note.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Integration Verification' (Protocol in workflow.md)
