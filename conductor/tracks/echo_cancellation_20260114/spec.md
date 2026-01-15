# Track Spec: Cross-platform Echo Cancellation (AEC) with Smart Detection

## Overview
This track implements Acoustic Echo Cancellation (AEC) to prevent the accompaniment/original audio from bleeding into the microphone signal during recording. It uses a hybrid strategy: Native OS capabilities on Mobile and a WebRTC-based software solution on Desktop.

## Functional Requirements
- **Hybrid AEC Implementation**:
    - **Android/iOS**: Configure `record` and `audio_session` to use native AEC modes (Voice Processing).
    - **Windows/macOS/Linux**: Integrate `webrtc-audio-processing` into the Rust core.
- **Reference Signal Injection (Desktop)**:
    - Rust core will decode the accompaniment file and use the samples as the reference signal for the WebRTC AEC module.
- **Smart Toggle & Headphone Detection**:
    - Use `audio_session` to detect if headphones (wired or Bluetooth) are plugged in.
    - **Logic**: 
        - If Headphones NOT detected -> Enable AEC by default.
        - If Headphones detected -> Disable AEC by default.
- **UI Integration**:
    - Add an "AEC" status indicator/toggle on the `PitchDetectorPage`.
    - Provide a manual override in the Settings drawer.

## Technical Details
- **Rust Dependencies**: `webrtc-audio-processing-sys` (or similar bindings).
- **Dart Dependencies**: `audio_session` for hardware detection.
- **Refactoring**: Update `Pitch` notifier to pass accompaniment playback timing/data to Rust if AEC is active.

## Non-Functional Requirements
- **Latency**: Ensure the WebRTC processing doesn't introduce >50ms latency.
- **Sync**: Digital reference signal must be tightly aligned with the mic capture (drift compensation).

## Acceptance Criteria
- [ ] On Mobile: Recording with speaker playback doesn't show the backing track notes in the pitch visualizer.
- [ ] On Desktop: WebRTC AEC effectively removes echo from the captured signal.
- [ ] Plugging in headphones automatically toggles AEC off in the UI.
- [ ] Unplugging headphones automatically toggles AEC on.

## Out of Scope
- Noise suppression (NS) and Automatic Gain Control (AGC) - unless bundled with WebRTC AEC.
- Hardware loopback capture.
