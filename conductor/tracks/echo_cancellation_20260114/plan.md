# Track Plan: Cross-platform Echo Cancellation (AEC) with Smart Detection

## Phase 1: Tech Stack & Rust Infrastructure [checkpoint: b5f0302]
- [x] Task: Update Tech Stack - Add `webrtc-audio-processing` to Rust and verify `audio_session` in Flutter
- [x] Task: Research and define Rust FFI interface for feeding reference audio and processing mic input
- [x] Task: Prototype Rust AEC wrapper for WebRTC
- [x] Task: Conductor - User Manual Verification 'Phase 1: Tech Stack & Rust Infrastructure' (Protocol in workflow.md) (b5f0302)

## Phase 2: Desktop Core - Software AEC Implementation
- [x] Task: Write failing tests for Rust AEC processing (Red Phase)
- [x] Task: Implement WebRTC AEC in Rust core (Green Phase)
- [x] Task: Implement internal accompaniment decoding in Rust for the reference signal
- [x] Task: Bridge AEC toggle and processing to Dart `Pitch` notifier
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Desktop Core - Software AEC Implementation' (Protocol in workflow.md)

## Phase 3: Hardware Awareness & Smart Logic
- [x] Task: Write failing tests for Headphone Detection & Smart Toggle (Red Phase)
- [x] Task: Implement Headphone detection using `audio_session`
- [x] Task: Implement Smart Toggle logic in `PitchState` (Auto-OFF with headphones)
- [x] Task: Update Mobile (Android/iOS) configurations for Native Voice Processing AEC
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Hardware Awareness & Smart Logic' (Protocol in workflow.md)

## Phase 4: UI Integration & Refinement
- [x] Task: Add AEC Status Indicator and Toggle to `PitchDetectorPage` control bar
- [x] Task: Add manual AEC override to Settings drawer
- [x] Task: Optimize sync between reference audio and microphone capture on Desktop
- [x] Task: Conductor - User Manual Verification 'Phase 4: UI Integration & Refinement' (Protocol in workflow.md)
