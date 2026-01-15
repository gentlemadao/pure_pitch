# Track Plan: Cross-platform Echo Cancellation (AEC) with Smart Detection

## Phase 1: Tech Stack & Rust Infrastructure
- [x] Task: Update Tech Stack - Add `webrtc-audio-processing` to Rust and verify `audio_session` in Flutter
- [x] Task: Research and define Rust FFI interface for feeding reference audio and processing mic input
- [x] Task: Prototype Rust AEC wrapper for WebRTC
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Tech Stack & Rust Infrastructure' (Protocol in workflow.md)

## Phase 2: Desktop Core - Software AEC Implementation
- [ ] Task: Write failing tests for Rust AEC processing (Red Phase)
- [ ] Task: Implement WebRTC AEC in Rust core (Green Phase)
- [ ] Task: Implement internal accompaniment decoding in Rust for the reference signal
- [ ] Task: Bridge AEC toggle and processing to Dart `Pitch` notifier
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Desktop Core - Software AEC Implementation' (Protocol in workflow.md)

## Phase 3: Hardware Awareness & Smart Logic
- [ ] Task: Write failing tests for Headphone Detection & Smart Toggle (Red Phase)
- [ ] Task: Implement Headphone detection using `audio_session`
- [ ] Task: Implement Smart Toggle logic in `PitchState` (Auto-OFF with headphones)
- [ ] Task: Update Mobile (Android/iOS) configurations for Native Voice Processing AEC
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Hardware Awareness & Smart Logic' (Protocol in workflow.md)

## Phase 4: UI Integration & Refinement
- [ ] Task: Add AEC Status Indicator and Toggle to `PitchDetectorPage` control bar
- [ ] Task: Add manual AEC override to Settings drawer
- [ ] Task: Optimize sync between reference audio and microphone capture on Desktop
- [ ] Task: Conductor - User Manual Verification 'Phase 4: UI Integration & Refinement' (Protocol in workflow.md)
