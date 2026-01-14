# Track Plan: Local Analysis Data Persistence & Audio Monitoring

## Phase 1: Database Infrastructure
- [x] Task: Write failing tests for Drift Database Service (Red Phase)
    - [x] Test schema creation (Sessions and NoteEvents tables).
    - [x] Test DAO operations for `sessions` and `note_events`.
- [x] Task: Implement `AppDatabase` using `drift` (Green Phase)
- [x] Task: Implement `SessionRepository` for structured data access
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Database Infrastructure' (Protocol in workflow.md)

## Phase 2: Analysis Caching Logic
- [ ] Task: Write failing tests for Analysis Caching in `Pitch` notifier (Red Phase)
    - [ ] Mock database and verify that `analyzeFile` checks for existing records.
    - [ ] Verify that results are saved after a successful analysis.
- [ ] Task: Implement Caching Logic in `Pitch` notifier (Green Phase)
    - [ ] Use `SessionRepository` to check for (name, size) matches.
    - [ ] Bypass ONNX inference if data is cached.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Analysis Caching Logic' (Protocol in workflow.md)

## Phase 3: Audio Monitoring (Karaoke Mode)
- [ ] Task: Update Tech Stack - Add `audioplayers` or `just_audio` (Protocol in workflow.md)
- [ ] Task: Write failing tests for Audio Playback Sync (Red Phase)
    - [ ] Verify that starting recording triggers audio playback when toggle is ON.
- [ ] Task: Implement Audio Player Service and Karaoke Toggle UI (Green Phase)
    - [ ] Add `Play Original Audio` toggle to `PitchDetectorPage`.
    - [ ] Synchronize playback with `_startCapture` and `_stopCapture`.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Audio Monitoring (Karaoke Mode)' (Protocol in workflow.md)
