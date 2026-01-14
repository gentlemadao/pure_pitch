# Track Plan: Timeline, Multi-level Monitoring, and Accompaniment Import

## Phase 1: Database & Data Layer
- [x] Task: Write failing tests for Session Schema Migration (Red Phase)
    - [x] Verify that `Sessions` table can store and retrieve `accompanimentPath`.
    - [x] Test migration from schema version 1 to 2.
- [x] Task: Update `AppDatabase` schema and implement migration logic (Green Phase)
- [x] Task: Update `SessionRepository` to support `accompanimentPath` in CRUD operations (Green Phase)
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Database & Data Layer' (Protocol in workflow.md)

## Phase 2: UI - Timeline & List Enhancements
- [ ] Task: Write failing tests for Timeline Rendering (Red Phase)
- [ ] Task: Implement `PitchTimeline` component in `PitchVisualizer` (Green Phase)
    - [ ] Add a horizontal ruler with time markers (seconds) below the pitch canvas.
- [ ] Task: Implement Accompaniment Status Indicator in `SessionsListPage` (Green Phase)
    - [ ] Add a visual badge or icon to list items that have a saved accompaniment path.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: UI - Timeline & List Enhancements' (Protocol in workflow.md)

## Phase 3: Logic - Multi-level Volume & Accompaniment Playback
- [ ] Task: Write failing tests for Volume Cycling & Accompaniment Sync (Red Phase)
- [ ] Task: Implement Volume Cycle logic in `Pitch` notifier (Green Phase)
- [ ] Task: Implement Accompaniment Selection & Sync in `Pitch` notifier (Green Phase)
    - [ ] Handle `just_audio` player instances for the accompaniment track.
- [ ] Task: Refactor `PitchDetectorPage` Control Layout (Green Phase)
    - [ ] Optimize action button placement (e.g., consolidate into a menu or toolbar) to reduce clutter.
    - [ ] Integrate new Volume and Accompaniment controls into this refined layout.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Logic - Multi-level Volume & Accompaniment Playback' (Protocol in workflow.md)
