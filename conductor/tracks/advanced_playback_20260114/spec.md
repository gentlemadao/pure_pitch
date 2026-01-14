# Track Spec: Timeline, Multi-level Monitoring, and Accompaniment Import

## Overview
This track enhances the user experience by adding visual time context, providing more control over audio monitoring volume, and enabling the use of accompaniment (backing) tracks alongside original audio sessions. It also includes a UI refactor to reduce clutter in the primary interface.

## Functional Requirements
- **Timeline Visualization**:
    - Add a horizontal time axis (ruler) at the bottom of the `PitchVisualizer`.
    - The ruler must scroll in sync with the pitch history and note events.
- **Multi-level Volume Control**:
    - Update the "Original Audio" playback to support three volume states: `0% (Muted)`, `40% (Low)`, and `70% (High)`.
    - A toggle button (cycling) will control these states.
- **Accompaniment Management**:
    - **Import**: Add an "Import Accompaniment" button in the `SessionsListPage` for each session.
    - **Status Indicator**: In the `SessionsListPage`, visually display whether a session has an accompaniment track linked.
    - **Persistence**: Store the `accompaniment_path` in the database `sessions` table.
    - **Playback**: Add a "Toggle Accompaniment" button to the `PitchDetectorPage` (visible when an accompaniment path exists).
    - **Synchronization**: Accompaniment playback must start/stop in sync with the recording (Karaoke mode) and manual playback.
- **UI Optimization**:
    - Refactor the `PitchDetectorPage` control layout (e.g., AppBar actions) to reduce visual clutter.
    - Use menus, toolbars, or drawer-based logic for secondary actions.

## Database Updates
- `sessions` table:
    - Add `accompaniment_path`: String (Optional)
- Migration: Update from schema version 1 to 2.

## UI Components
- **Timeline**: A custom painter or widget rendered below the pitch canvas.
- **Volume Button**: Updates its icon/overlay to indicate the current volume level (0, 40%, 70%).
- **Accompaniment Toggle**: A dedicated icon button (e.g., music note icon) on the main page.
- **Session List Item**: Add an icon or badge to indicate accompaniment presence.

## Non-Functional Requirements
- **Performance**: Ensure the scrolling timeline does not cause UI lag in long sessions.
- **Sync Accuracy**: Accompaniment and Original audio must start at the same millisecond to maintain musical alignment.

## Acceptance Criteria
- [ ] Horizontal timeline is visible and accurate relative to the pitch data.
- [ ] Tapping the volume button cycles through 0%, 40%, and 70% volume.
- [ ] Accompaniment files can be imported from the history list and are saved in the database.
- [ ] The Saved Sessions list clearly indicates which sessions have accompaniments.
- [ ] If an accompaniment exists, it plays in sync when the toggle is enabled.
- [ ] The primary UI feels less cluttered after the refactor.

## Out of Scope
- Granular volume control (e.g. 0-100% slider).
- Waveform visualization on the timeline.
