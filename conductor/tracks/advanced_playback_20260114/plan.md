# Track Plan: Timeline, Multi-level Monitoring, and Accompaniment Import

## Phase 1: Database & Data Layer [checkpoint: 78ea207]
- [x] Task: Write failing tests for Session Schema Migration (Red Phase)
    - [x] Verify that `Sessions` table can store and retrieve `accompanimentPath`.
    - [x] Test migration from schema version 1 to 2.
- [x] Task: Update `AppDatabase` schema and implement migration logic (Green Phase)
- [x] Task: Update `SessionRepository` to support `accompanimentPath` in CRUD operations (Green Phase)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Database & Data Layer' (Protocol in workflow.md) (78ea207)

## Phase 2: UI - Timeline & List Enhancements [checkpoint: e43e5e4]
- [x] Task: Write failing tests for Timeline Rendering (Red Phase)
- [x] Task: Implement `PitchTimeline` component in `PitchVisualizer` (Green Phase)
- [x] Task: Implement Accompaniment Status Indicator in `SessionsListPage` (Green Phase)
    - [x] Add a visual badge or icon to list items that have a saved accompaniment path.
- [x] Task: Conductor - User Manual Verification 'Phase 2: UI - Timeline & List Enhancements' (Protocol in workflow.md) (e43e5e4)

## Phase 3: Logic - Multi-level Volume & Accompaniment Playback
- [x] Task: Write failing tests for Volume Cycling & Accompaniment Sync (Red Phase)
- [x] Task: Implement Volume Cycle logic in `Pitch` notifier (Green Phase)
- [x] Task: Implement Accompaniment Selection & Sync in `Pitch` notifier (Green Phase)
- [x] Task: Refactor `PitchDetectorPage` Control Layout (Green Phase)
- [x] Task: Conductor - User Manual Verification 'Phase 3: Logic - Multi-level Volume & Accompaniment Playback' (Protocol in workflow.md)

## Phase 3.5: UI Refinement - Drawer Navigation [checkpoint: 4c788f7]
- [x] Task: Implement Navigation Drawer in `PitchDetectorPage` (Green Phase)
    - [x] Move History and Logs navigation to the drawer.
    - [x] Replace "..." menu with a Drawer toggle.
- [x] Task: Conductor - User Manual Verification 'Phase 3.5: UI Refinement - Drawer Navigation' (Protocol in workflow.md)
