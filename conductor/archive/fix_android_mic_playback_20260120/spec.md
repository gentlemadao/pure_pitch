# Track Specification: Fix Android Mic Input during Playback

## Overview
Users report that on Android devices, the microphone input signal (visualized by the vocal activity chart) drops to zero or stops being detected when accompaniment audio is playing, even though the OS indicates the microphone is active.

## Problem Analysis
- **Symptoms:** Vocal activity bars disappear/stay empty when accompaniment starts.
- **Platform:** Android (Confirmed).
- **Potential Causes:**
    - `AudioSession` configuration conflicts (mode `measurement` vs `playAndRecord`).
    - Android-specific `AudioSource` (e.g., `mic` vs `voiceCommunication`).
    - Priority handling between `just_audio` (playback) and `record` (capture).

## Functional Requirements
- **Simultaneous Play & Record:** The app MUST successfully capture microphone input (non-zero amplitude) while playing accompaniment audio on Android.
- **Audio Routing:** Audio output should go to the speaker/headphones as appropriate, and input should come from the mic.

## Investigation Plan
1.  **Reproduce:** (Requires Android device/emulator). Since I am an AI, I rely on code analysis and user feedback.
2.  **Review Config:** Check `AudioSession` setup in `PitchProvider`.
3.  **Review Dependencies:** Check for known issues between `record`, `just_audio`, and `audio_session`.

## Acceptance Criteria
- [ ] Microphone input signal is detected and visualized (amplitude > 0) while accompaniment is playing on Android.
- [ ] No regression on iOS or Desktop platforms.
