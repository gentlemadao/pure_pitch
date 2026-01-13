# Track Spec: Monophonic Stability with Hysteresis

## Overview
The current monophonic note extraction logic is overly sensitive to frame-by-frame probability fluctuations, especially on complex tones like chords. This results in the melody line breaking into short, discarded fragments. This track implements a hysteresis/inertia mechanism to stabilize the active note, preventing it from being dropped or switched due to minor dips in confidence.

## Functional Requirements
- **Note Inertia/Hysteresis**:
    - In `extract_notes`, when a note is currently active, it should be given a bias.
    - **Logic**: If an active note's probability in the current frame is still above a "continuation threshold" (e.g., 0.3), it should remain active, even if another note's probability is slightly higher (but below the main 0.5 threshold for *new* notes).
    - This will prevent the active note from being dropped due to momentary dips in confidence.
- **Stable Note Switching**:
    - A switch to a new note should only occur if the new note's probability is significantly higher than the current active note's probability.

## Acceptance Criteria
- [ ] Analysis of `chord_c_major.wav` produces a single, continuous note bar (the dominant pitch).
- [ ] Rust unit tests verify that a sustained note with minor confidence dips is not fragmented.

## Out of Scope
- Major changes to the chunking or merging logic. This is a fix within the `extract_notes` function.
