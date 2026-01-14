# Track Spec: Local Analysis Data Persistence & Audio Monitoring

## Overview
Currently, the user must wait for the Basic Pitch model to analyze an audio file every time they select it. This track implements a caching/persistence layer using SQLite to store `NoteEvent` data for instantaneous loading. Additionally, it enables playback of the original audio file during recording, mimicking a karaoke experience.

## Functional Requirements
- **Local Persistence**: Store analysis results (List of `NoteEvent`) in a local SQLite database.
- **Session Management**:
    - Save the **original audio file path** in the database record.
    - Save `NoteEvent` data (start time, duration, pitch, confidence).
- **Automatic Matching**: When an audio file is selected via `FilePicker`, check the database for an existing entry matching the **file name** and **file size**.
    - If found: Bypass inference and load saved data immediately.
- **Audio Monitoring (Karaoke Mode)**:
    - Add a "Play Original Audio" toggle button to the `PitchDetectorPage`.
    - If enabled: When the user starts recording (`toggleCapture`), the app plays the original audio file in sync.
    - If disabled: Recording proceeds silently (as currently implemented).

## Database Schema
- `sessions` table:
    - `id`: Primary Key
    - `file_path`: String (Path to original audio)
    - `file_name`: String
    - `file_size`: Integer (Bytes)
    - `duration_seconds`: Double
    - `created_at`: DateTime
- `note_events` table:
    - `session_id`: Foreign Key
    - `start_time`: Double
    - `duration`: Double
    - `midi_note`: Integer
    - `confidence`: Double

## Non-Functional Requirements
- **UI Responsiveness**: Database checks and loading should be near-instant (<500ms).
- **Synchronization**: Audio playback must start precisely when recording starts to ensure the user's voice aligns with the backing track.
- **Latency**: Audio playback should introduce minimal latency to avoid throwing off the singer.

## Acceptance Criteria
- [ ] Selecting a previously analyzed file loads results instantly without re-analysis.
- [ ] Toggling "Play Original Audio" ON plays the backing track when "Record" is pressed.
- [ ] Toggling "Play Original Audio" OFF keeps the backing track silent during recording.
- [ ] Stopping recording automatically stops the backing track playback.
- [ ] Modifying the original file (changing size) triggers re-analysis.

## Out of Scope
- Storing the raw high-frequency `history` points.
- Cloud sync.
- Vocal removal/isolation from the original track (just plays the file as-is).
