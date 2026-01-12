# Track Spec: Audio Test Data Generation & Accuracy Validation

## Overview
This track aims to create a robust testing mechanism for the `analyzeAudioFile` method by programmatically generating audio files with precisely known pitch, timing, and structure. This will allow for automated regression testing and accuracy benchmarking of the Basic Pitch integration.

## Functional Requirements
- **Audio Generation Utility**: Implement a utility (likely in Dart/Rust bridge or a dedicated test helper) to generate audio data with specific parameters:
    - Pure sine waves (A4=440Hz, etc.).
    - Complex waveforms (sawtooth, square) to challenge the pitch detector.
    - Monophonic sequences (scales, arpeggios).
    - Polyphonic audio (chords) to test Basic Pitch's polyphonic capabilities.
- **Automated Test Suite**: Create integration tests in `test/` that:
    - Generate a specific "ground truth" audio file.
    - Pass the file to `analyzeAudioFile`.
    - Compare the resulting `List<NoteEvent>` against the ground truth.
- **Accuracy Benchmarking**: Implement logic to calculate and report accuracy metrics:
    - Precision/Recall for note detection.
    - Timing error tolerance (start time and duration).
    - Pitch accuracy (MIDI note matching).

## Non-Functional Requirements
- **Efficiency**: Audio generation should be fast enough to run as part of a standard test suite.
- **Reproducibility**: Use fixed seeds if any randomness is involved to ensure tests are deterministic.

## Acceptance Criteria
- [ ] Ability to generate a WAV/MP3 file with a specified MIDI sequence.
- [ ] Integration test passes when `analyzeAudioFile` correctly identifies a simple C Major scale.
- [ ] Integration test passes when `analyzeAudioFile` correctly identifies a triad chord.
- [ ] Test output includes an accuracy report (e.g., "Detected 12/12 notes correctly").

## Out of Scope
- Real-time microphone testing (this track focuses on file-based analysis).
- Advanced noise/reverb simulation (keep to "clean" synthesis for now).
