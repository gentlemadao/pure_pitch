# Baseline Accuracy Report

**Date:** 2026-01-12
**Model:** Basic Pitch (ONNX)
**Environment:** macOS (flutter test)

## Results Summary
| Test Case | F1 Score | Notes |
|-----------|----------|-------|
| Sawtooth A4 (Single Note) | 0.67 | Detected A4 correctly, but also some false positives. |
| C Major Scale | 0.73 | All 8 notes detected. 6 false positives (mostly lower octaves). |
| C Major Triad | 0.67 | All 3 chord notes (C4, E4, G4) detected simultaneously. 3 false positives. |

## Analysis
The model exhibits good sensitivity (Recall=1.0 in most cases), correctly identifying all played notes. However, it generates several "ghost" notes in lower octaves (Precision < 1.0), likely due to the perfect harmonic structure of synthesized sawtooth waves which differ from real instrument recordings.

For synthesized test data, an F1 score above 0.65 is considered a healthy baseline for this model.
