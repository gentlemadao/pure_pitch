# Track Spec: Persistent and Smooth Real-time Pitch Visualization

## Overview
Currently, the real-time pitch visualizer only keeps the last 6 seconds of data and exhibits "sharp angles" (jitter) and sudden data "disappearances" due to relative time anchoring. This track aims to implement a persistent session history, a Wall Clock-based smooth rendering system, and frequency smoothing filters.

## Functional Requirements
- **Persistent Session History**:
    - Remove the 6-second `cutoff` in `PitchState`. All data captured since clicking "Record" must be retained until the recording is stopped or a new one starts.
- **Wall Clock Rendering**:
    - Update `PitchVisualizer` to use the actual system time (`DateTime.now()`) for time-to-X coordinate mapping.
    - This ensures that data flows smoothly from right to left even when the input stream is intermittent.
- **Smoothing Filter**:
    - Implement a smoothing algorithm (e.g., EMA or Median) to eliminate "sharp angles" caused by momentary frequency estimation errors.
- **Post-recording Review**:
    - Ensure the `PitchVisualizer` (which already uses `SingleChildScrollView`) allows the user to scroll through the entire captured history once the recording has stopped.

## Non-Functional Requirements
- **Memory Management**: While data is persistent during a session, ensure the number of points stored doesn't lead to UI performance degradation (e.g., consider downsampling or efficient rendering for very long sessions).

## Acceptance Criteria
- [ ] **Fluid Right-to-Left Flow**: During recording, the curve moves steadily, even if singing stops momentarily.
- [ ] **No Data Disappearance**: Previously sung notes do not "pop" out of existence until they naturally scroll off the left edge.
- [ ] **Full History Review**: After stopping a recording, the user can manually scroll back to see the beginning of the session.
- [ ] **Smooth Curves**: No more jagged "sharp angles" during steady singing.

## Out of Scope
- Permanent database storage for sessions (this track is about in-memory persistence for the current session).
