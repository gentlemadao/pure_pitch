# Track Spec: Global Monophonic Enforcement

## Overview
While the current implementation enforces monophony within a single chunk (2 seconds), it does not handle overlaps or conflicts between notes that span across chunk boundaries or are simply overlapping in the final merged list. This track implements a global post-processing pass to enforce strict monophony across the entire audio file.

## Functional Requirements
- **Global Monophonic Pass**:
    - Implement a new function `enforce_global_monophony(notes: Vec<NoteEvent>) -> Vec<NoteEvent>` in `rust/src/api/pitch.rs`.
    - Sort all notes by `start_time`.
    - Iterate through the sorted notes and resolve overlaps.
- **Conflict Resolution Strategy**:
    - If `Note B` starts before `Note A` ends (overlap):
        - Compare their `confidence`.
        - **If `Note B` is more confident**: Truncate `Note A`'s end time to `Note B`'s start time.
        - **If `Note A` is more confident**: Delay `Note B`'s start time to `Note A`'s end time (or discard `Note B` if its duration becomes too short).
        - **If equal confidence**: Prefer the earlier note (`Note A`), delay `Note B`.
- **Minimum Duration Check**:
    - After truncation/delay, if a note's duration falls below the minimum threshold (100ms), discard it.

## Acceptance Criteria
- [ ] Rust unit tests verify that overlapping notes with different pitches are resolved according to confidence.
- [ ] Integration tests confirm that `scale_c_major_saw.wav` analysis contains no temporally overlapping notes.

## Out of Scope
- Polyphonic support (this is explicitly a monophonic mode feature).
