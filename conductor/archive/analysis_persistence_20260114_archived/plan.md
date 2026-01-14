# Track Plan: Local Analysis Data Persistence & Audio Monitoring

## Phase 1: Database Infrastructure [checkpoint: 5d7a24b]
- [x] Task: Write failing tests for Drift Database Service (Red Phase)
    - [x] Test schema creation (Sessions and NoteEvents tables).
    - [x] Test DAO operations for `sessions` and `note_events`.
- [x] Task: Implement `AppDatabase` using `drift` (Green Phase)
- [x] Task: Implement `SessionRepository` for structured data access
- [x] Task: Conductor - User Manual Verification 'Phase 1: Database Infrastructure' (Protocol in workflow.md) (5d7a24b)

## Phase 2: Analysis Caching Logic
- [x] Task: Write failing tests for Analysis Caching in `Pitch` notifier (Red Phase)
    - [x] Mock database and verify that `analyzeFile` checks for existing records.
    - [x] Verify that results are saved after a successful analysis.
- [x] Task: Implement Caching Logic in `Pitch` notifier (Green Phase)
    - [x] Use `SessionRepository` to check for (name, size) matches.
    - [x] Bypass ONNX inference if data is cached.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Analysis Caching Logic' (Protocol in workflow.md)

## Phase 2.5: Saved Sessions UI [checkpoint: 846eafe]
- [x] Task: Write failing tests for Sessions List UI (Red Phase)
- [x] Task: Implement `SessionsList` page and "History" access (Green Phase)
- [x] Task: Implement Load & Delete functionality in `SessionsList`
- [x] Task: Conductor - User Manual Verification 'Phase 2.5: Saved Sessions UI' (Protocol in workflow.md) (846eafe)

## Phase 3: Audio Monitoring (Karaoke Mode) [checkpoint: 52524c4]
- [x] Task: Update Tech Stack - Add `audioplayers` or `just_audio` (Protocol in workflow.md)
- [x] Task: Write failing tests for Audio Playback Sync (Red Phase)
- [x] Task: Implement Audio Player Service and Karaoke Toggle UI (Green Phase)
- [x] Task: Conductor - User Manual Verification 'Phase 3: Audio Monitoring (Karaoke Mode)' (Protocol in workflow.md)
