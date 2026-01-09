# Track Plan: Complete Offline Audio Analysis

## Phase 1: Model Asset & Rust Setup
- [ ] Task: Model Management
    - [ ] Copy `/Volumes/M2/PythonProjects/basic_pitch.onnx` to `assets/models/basic_pitch.onnx`.
    - [ ] Update `pubspec.yaml` to include the model asset.
    - [ ] Implement a helper in Rust/Dart to locate the model file path at runtime.
    - [ ] Commit: `feat(assets): Add Basic Pitch ONNX model`

- [ ] Task: Rust ORT Session Initialization
    - [ ] Update `analyze_audio_file` in `rust/src/api/pitch.rs` to load the ONNX model.
    - [ ] Configure `ort` session with Graph Optimization Level 3.
    - [ ] Verify input/output node names match `input_2`, `note`, `onset`, `contour`.
    - [ ] Test: Write a Rust test to verify model loads successfully.
    - [ ] Commit: `feat(rust): Initialize ORT session with Basic Pitch model`

## Phase 2: Preprocessing & Inference
- [ ] Task: Audio Preprocessing Implementation
    - [ ] Modify `decode_and_resample` to ensure exact 22,050 Hz output.
    - [ ] Implement audio normalization (if needed, usually float -1.0 to 1.0).
    - [ ] Shape the `Vec<f32>` into `ndarray::Array3<f32>` with shape `[1, n_samples, 1]`.
    - [ ] Test: Verify tensor shape matches model expectation.
    - [ ] Commit: `feat(rust): Implement audio preprocessing for Basic Pitch`

- [ ] Task: Run Inference
    - [ ] Execute `session.run` with the input tensor.
    - [ ] Extract `note`, `onset`, and `contour` output tensors.
    - [ ] Test: Run inference on a generated sine wave and assert output shapes.
    - [ ] Commit: `feat(rust): Execute Basic Pitch inference`

## Phase 3: Post-processing (The Heavy Lifting)
- [ ] Task: Implement Note Extraction Logic
    - [ ] Create a new module `rust/src/api/basic_pitch_postproc.rs`.
    - [ ] Implement `extract_notes(frames: Array3<f32>, onsets: Array3<f32>) -> Vec<NoteEvent>`.
    - [ ] Logic:
        1. Iterate through time frames.
        2. Filter bins > threshold (0.3).
        3. Use onsets to refine start times.
        4. Join consecutive frames into single `NoteEvent`s.
    - [ ] Test: Unit test with synthetic probability maps.
    - [ ] Commit: `feat(rust): Implement Basic Pitch post-processing`

- [ ] Task: Integrate Post-processing
    - [ ] Call `extract_notes` in `analyze_audio_file`.
    - [ ] Return the resulting `Vec<NoteEvent>` to Dart.
    - [ ] Commit: `feat(rust): Connect inference to post-processing`

## Phase 4: UI Visualization & Polish
- [ ] Task: Update Pitch State & UI
    - [ ] Ensure `PitchProvider` correctly handles the `List<NoteEvent>`.
    - [ ] Update `PitchVisualizer` to render `NoteEvent`s (horizontal bars) on the canvas.
        - Map `start_time` to X pixel.
        - Map `midi_note` to Y pixel.
        - Map `duration` to width.
    - [ ] Commit: `feat(ui): Visualize offline analysis results`

- [ ] Task: End-to-End Testing
    - [ ] Verify the full flow: Select File -> Process -> See Notes.
    - [ ] Optimize thresholds if too many/few notes are detected.
    - [ ] Commit: `fix: Tune analysis parameters`

- [ ] Task: Conductor - User Manual Verification 'Phase 4: UI Visualization & Polish' (Protocol in workflow.md)
