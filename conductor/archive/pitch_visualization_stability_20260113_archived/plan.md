# Track Plan: Persistent and Smooth Real-time Pitch Visualization

## Phase 1: Persistence & Wall Clock Anchor [checkpoint: 3fd394d]
- [x] Task: Write failing tests for History Persistence (Red Phase) (3fd394d)
- [x] Task: Implement History Persistence in `Pitch` notifier (Green Phase) (3fd394d)
- [x] Task: Write failing tests for Wall Clock Rendering in `PitchVisualizer` (Red Phase) (3fd394d)
- [x] Task: Implement Wall Clock Anchor in `PitchVisualizer` (Green Phase) (3fd394d)
- [x] Task: UX Refinement - Fixed Labels & Adaptive Y-axis (3fd394d)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Persistence & Wall Clock Anchor' (Protocol in workflow.md)

## Phase 2: Smoothing Filter [checkpoint: 8ff03ca]
- [x] Task: Write failing tests for Pitch Smoothing (Red Phase) (e55f6e2)
    - [x] Simulate noisy data (spikes) and assert that the output curve is dampened.
- [x] Task: Implement EMA & Median Smoothing Filter in `Pitch` notifier (Green Phase) (e55f6e2)
    - [x] Add filters to raw frequency stream and implement vocal range gating.


## Phase 3: UX & Performance [checkpoint: d39816f]
- [x] Task: Optimize `PitchVisualizer` for long-session scrolling (d39816f)
    - [x] Ensure `SingleChildScrollView` handles growing history and enables post-stop review.
- [x] Task: Conductor - User Manual Verification 'Phase 3: UX & Performance' (Protocol in workflow.md) (d39816f)
