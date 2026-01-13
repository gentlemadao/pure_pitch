# Track Plan: Persistent and Smooth Real-time Pitch Visualization

## Phase 1: Persistence & Wall Clock Anchor
- [x] Task: Write failing tests for History Persistence (Red Phase) (042b74f)
    - [x] Verify `history` does not discard data after 6 seconds.
- [~] Task: Implement History Persistence in `Pitch` notifier (Green Phase)
    - [ ] Remove cutoff logic and ensure session-long data retention.
- [ ] Task: Write failing tests for Wall Clock Rendering in `PitchVisualizer` (Red Phase)
    - [ ] Verify X-coordinate calculation remains stable regardless of input timing.
- [ ] Task: Implement Wall Clock Anchor in `PitchVisualizer` (Green Phase)
    - [ ] Refactor painter to use system time for smooth, continuous flow.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Persistence & Wall Clock Anchor' (Protocol in workflow.md)

## Phase 2: Smoothing Filter
- [ ] Task: Write failing tests for Pitch Smoothing (Red Phase)
    - [ ] Simulate noisy data and assert that the output curve is dampened.
- [ ] Task: Implement EMA Smoothing Filter in `Pitch` notifier (Green Phase)
    - [ ] Add configurable Exponential Moving Average filter to raw frequency stream.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Smoothing Filter' (Protocol in workflow.md)

## Phase 3: UX & Performance
- [ ] Task: Optimize `PitchVisualizer` for long-session scrolling
    - [ ] Ensure `SingleChildScrollView` handles growing history and enables post-stop review.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UX & Performance' (Protocol in workflow.md)
