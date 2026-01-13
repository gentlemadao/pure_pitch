# Track Plan: Monophonic Stability with Hysteresis

## Phase 1: Rust Implementation & Testing
- [~] Task: Implement Note Inertia Logic
    - [ ] Refactor `extract_notes` in `rust/src/api/basic_pitch_postproc.rs` to introduce a "continuation threshold".
    - [ ] Implement the logic to favor the currently active note if its probability is still reasonably high.
- [ ] Task: Write Rust Unit Tests (Red Phase)
    - [ ] Add a test case simulating a sustained note with fluctuating probabilities, asserting it is not broken.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Rust Implementation & Testing' (Protocol in workflow.md)

## Phase 2: Integration Verification
- [x] Task: Verify with `chord_c_major.wav`
    - [x] Run the analysis on `chord_c_major.wav`.
    - [x] Confirm that the output is a single, continuous note.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Integration Verification' (Protocol in workflow.md)
