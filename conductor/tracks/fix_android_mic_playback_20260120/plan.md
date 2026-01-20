# Track Plan: Fix Android Mic Input during Playback

## Phase 1: Configuration Analysis & Fix [Completed - Ineffective]
- [x] Task: Update AudioSession Configuration
    - [x] Change `AndroidAudioAttribute` usage to `media` (verify if `game` or `assistant` is better).
    - [x] Experiment with `avAudioSessionMode` (e.g., `default` instead of `measurement`) as `measurement` might be strict on Android about concurrency.
    - [x] **Action:** Modify `_initAudioSession` in `lib/features/pitch/presentation/providers/pitch_provider.dart`.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Configuration Analysis & Fix' (Protocol in workflow.md)

## Phase 3: Focus Management & Source Re-eval [Completed - Ineffective]
- [x] Task: Adjust Audio Focus [222cfa2]
    - [x] Change `androidAudioFocusGainType` to `gainTransient` or `gainTransientMayDuck`.
    - [x] Revert `AndroidAudioSource` to `unprocessed` (avoid `voiceCommunication` forcing HW AEC).
    - [x] Revert `avAudioSessionMode` to `default` (avoid `videoChat` side effects).
- [x] Task: Conductor - User Manual Verification 'Phase 3: Focus Management & Source Re-eval' (Protocol in workflow.md)

## Phase 4: AEC Initialization Debugging [Completed]
- [x] Task: Wrap AEC Init in Try-Catch
    - [x] Add explicit logging for AEC initialization success/failure.
    - [x] Ensure failure in AEC init doesn't silently block recording.
    - [x] **Action:** Modify `_startCapture` in `PitchProvider`.
- [x] Task: Conductor - User Manual Verification 'Phase 4: AEC Initialization Debugging' (Protocol in workflow.md)

## Phase 5: Optimize AEC Initialization (Pre-loading & Caching) [checkpoint: 92385c5]
- [x] Task: Implement AEC Pre-loading [83a987f]
    - [x] Create `_updateAecConfig()` method in `PitchProvider`.
    - [x] Call this method whenever `currentFilePath`, `accompanimentPath`, `isAccompanimentEnabled`, or `monitoringVolume` changes.
    - [x] Remove blocking `aecInit` call from `_startCapture`.
- [x] Task: Implement Rust-side Audio Caching [83a987f]
    - [x] Create a static `AUDIO_CACHE` in `rust/src/api/pitch.rs`.
    - [x] Update `analyze_audio_file` to cache decoded PCM data.
    - [x] Update `aec_init` to use cached data if available, avoiding re-decoding.
- [x] Task: Conductor - User Manual Verification 'Phase 5: Optimize AEC Initialization (Pre-loading & Caching)' (Protocol in workflow.md) [92385c5]
