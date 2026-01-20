# Track Plan: Vocal Activity Amplitude Chart Overlay

## Phase 1: Settings & Data Infrastructure [checkpoint: 32b5b92]
- [x] Task: Implement `vocalActivityEnabled` in Settings [a19e9cb]
    - [x] Add `showVocalActivity` field to `SettingsState` and `SettingsNotifier` (Red/Green)
    - [x] Update `StorageService` to persist this setting
- [x] Task: Extend Pitch Data Model [3a3558a]
    - [x] Update the pitch sample data structure (e.g., `PitchPoint` or equivalent) to include an `amplitude` field (Red/Green)
    - [x] Update the Rust-Dart bridge if necessary to ensure amplitude is passed along with frequency/confidence
- [x] Task: Conductor - User Manual Verification 'Phase 1: Settings & Data Infrastructure' (Protocol in workflow.md) [32b5b92]

## Phase 2: Recording & Synchronization
- [ ] Task: Capture and Store Amplitude History
    - [ ] Modify `PitchNotifier` to capture RMS/Peak amplitude from the microphone stream (Red/Green)
    - [ ] Store amplitude samples in the same history buffer as pitch samples to ensure temporal alignment
- [ ] Task: Sync Data with Time Ruler
    - [ ] Ensure amplitude data correctly responds to the time scaling (5s vs 10s window) and horizontal scrolling
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Recording & Synchronization' (Protocol in workflow.md)

## Phase 3: Visualization & UI Integration
- [ ] Task: Implement Vocal Activity Painter
    - [ ] Create `VocalActivityPainter` to draw stacked bars (Green for voiced, Gray for unvoiced) based on the amplitude data (Red/Green)
    - [ ] Apply semi-transparency and ensure the visual style matches the "glowing/premium" aesthetic
- [ ] Task: Integrate Overlay in Pitch Detector Page
    - [ ] Add the `VocalActivityChart` widget as a `Positioned` overlay at the bottom of the pitch chart area
    - [ ] Ensure it only renders when `showVocalActivity` is enabled in settings
- [ ] Task: Add Toggle to Settings Drawer
    - [ ] Add a "Vocal Activity Chart" Switch to the settings drawer UI
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Visualization & UI Integration' (Protocol in workflow.md)

## Phase 4: Refinement & Performance
- [ ] Task: Optimize Rendering Performance
    - [ ] Verify that adding the overlay doesn't degrade frame rates during recording (Red/Green)
    - [ ] Use `RepaintBoundary` or similar optimizations if necessary
- [ ] Task: Final Visual Polish
    - [ ] Fine-tune the Green/Gray color balance and transparency levels for readability
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Refinement & Performance' (Protocol in workflow.md)
