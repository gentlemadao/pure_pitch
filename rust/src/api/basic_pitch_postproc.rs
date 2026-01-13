use ndarray::Array3;
use crate::api::pitch::NoteEvent;

#[flutter_rust_bridge::frb(ignore)]
pub fn extract_notes(frames: Array3<f32>, _onsets: Array3<f32>) -> Vec<NoteEvent> {
    let threshold = 0.5; // f32
    let continuation_threshold = 0.3; // Hysteresis floor
    let switch_threshold_delta = 0.1; // Hysteresis switch cost
    
    let min_duration_ms = 0.1f64;
    let hop_length = 512.0f64;
    let sample_rate = 22050.0f64;
    let frame_duration = hop_length / sample_rate;
    let min_duration_frames = (min_duration_ms / frame_duration).ceil() as usize;

    let mut events = Vec::new();
    let n_frames = frames.shape()[1];
    let n_bins = frames.shape()[2];

    let mut current_note_start: Option<usize> = None;
    let mut current_note_bin: Option<usize> = None;
    let mut current_note_prob_sum: f32 = 0.0;

    for t in 0..n_frames {
        // Find best bin for this frame
        let mut best_f = 0;
        let mut max_p = 0.0;
        
        for f in 0..n_bins {
            let p = frames[[0, t, f]];
            if p > max_p {
                max_p = p;
                best_f = f;
            }
        }

        // Logic with Inertia
        let mut keep_current = false;
        
        if let Some(current_bin) = current_note_bin {
             let current_p = frames[[0, t, current_bin]];
             if current_p > continuation_threshold {
                 // Current note is still viable
                 if max_p > threshold {
                     if best_f == current_bin {
                         keep_current = true;
                     } else {
                         // Competing note is strong. Switch only if significantly stronger.
                         if max_p > current_p + switch_threshold_delta {
                             keep_current = false; // Switch
                         } else {
                             keep_current = true; // Inertia
                         }
                     }
                 } else {
                     // No new strong note, but current is viable (dip)
                     keep_current = true;
                 }
             }
        }

        if keep_current {
             if let Some(bin) = current_note_bin {
                 let current_p = frames[[0, t, bin]];
                 current_note_prob_sum += current_p;
             }
        } else {
            // Close old if exists
             if let Some(start) = current_note_start {
                 if let Some(bin) = current_note_bin {
                     let duration = t - start;
                     if duration >= min_duration_frames {
                         events.push(NoteEvent {
                             start_time: start as f64 * frame_duration,
                             duration: duration as f64 * frame_duration,
                             midi_note: (bin + 21) as i32,
                             confidence: current_note_prob_sum / duration as f32,
                         });
                     }
                 }
             }
             
             // Start new or stop
             if max_p > threshold {
                 current_note_start = Some(t);
                 current_note_bin = Some(best_f);
                 current_note_prob_sum = max_p;
             } else {
                 current_note_start = None;
                 current_note_bin = None;
                 current_note_prob_sum = 0.0;
             }
        }
    }
    
    // Close pending notes
    if let Some(start) = current_note_start {
        if let Some(bin) = current_note_bin {
            let duration = n_frames - start;
            if duration >= min_duration_frames {
                events.push(NoteEvent {
                    start_time: start as f64 * frame_duration,
                    duration: duration as f64 * frame_duration,
                    midi_note: (bin + 21) as i32,
                    confidence: current_note_prob_sum / duration as f32,
                });
            }
        }
    }

    events
}

#[cfg(test)]
mod tests {
    use super::*;
    use ndarray::Array;

    #[test]
    fn test_extract_notes_simple() {
        let mut frames = Array::zeros((1, 10, 88));
        let onsets = Array::zeros((1, 10, 88));
        
        // Note at bin 60 from frame 2 to 8 (length 6)
        // 0.9 > threshold 0.3
        for i in 2..8 {
            frames[[0, i, 60]] = 0.9;
        }
        
        let notes = extract_notes(frames, onsets);
        
        assert_eq!(notes.len(), 1);
        let note = &notes[0];
        assert_eq!(note.midi_note, 60 + 21);
        
        let frame_duration = 512.0 / 22050.0;
        assert!((note.start_time - 2.0 * frame_duration).abs() < 1e-6);
        assert!((note.duration - 6.0 * frame_duration).abs() < 1e-6);
    }

    #[test]
    fn test_denoising_short_notes() {
        let mut frames = Array::zeros((1, 10, 88));
        let onsets = Array::zeros((1, 10, 88));
        
        // Note at bin 60, duration 3 frames (~70ms)
        // Should be filtered if min duration is 100ms
        for i in 2..5 {
            frames[[0, i, 60]] = 0.9;
        }
        
        let notes = extract_notes(frames, onsets);
        assert_eq!(notes.len(), 0);
    }

    #[test]
    fn test_monophonic_enforcement() {
        let mut frames = Array::zeros((1, 20, 88));
        let onsets = Array::zeros((1, 20, 88));
        
        // Note 1: bin 60, prob 0.9, frame 2-10
        for i in 2..10 {
            frames[[0, i, 60]] = 0.9;
        }
        
        // Note 2: bin 65, prob 0.6, frame 2-10 (simultaneous)
        // Should be removed because 0.6 < 0.9
        for i in 2..10 {
            frames[[0, i, 65]] = 0.6;
        }
        
        let notes = extract_notes(frames, onsets);
        assert_eq!(notes.len(), 1);
        assert_eq!(notes[0].midi_note, 60 + 21);
    }

    #[test]
    fn test_note_inertia() {
        let mut frames = Array::zeros((1, 20, 88));
        let onsets = Array::zeros((1, 20, 88));
        
        // Note at bin 60.
        // Frames 2-5: strong (0.8)
        for i in 2..6 {
            frames[[0, i, 60]] = 0.8;
        }
        // Frames 6-8: dip (0.4) - below 0.5 threshold, but above continuation 0.3
        for i in 6..9 {
            frames[[0, i, 60]] = 0.4;
        }
        // Frames 9-12: strong again (0.8)
        for i in 9..13 {
            frames[[0, i, 60]] = 0.8;
        }
        
        let notes = extract_notes(frames, onsets);
        
        // Without inertia, this would split into two notes (2-6 and 9-13).
        // With inertia, it should be one continuous note (2-13).
        assert_eq!(notes.len(), 1);
        
        // Expected duration: 13-2 = 11 frames.
        // 11 * (512/22050) = 0.255s
        // Tolerance check
        let frame_duration = 512.0 / 22050.0;
        assert!((notes[0].duration - 11.0 * frame_duration).abs() < 1e-4);
    }

    #[test]
    fn test_fluctuating_probabilities() {
        let mut frames = Array::zeros((1, 30, 88));
        let onsets = Array::zeros((1, 30, 88));
        
        // Note at bin 60
        // Sequence of probabilities: 0.9, 0.4, 0.9, 0.35, 0.9, 0.45, 0.9
        // All above continuation_threshold (0.3), but some below main threshold (0.5)
        let probs = [0.9, 0.4, 0.9, 0.35, 0.9, 0.45, 0.9];
        for (i, &p) in probs.iter().enumerate() {
            frames[[0, i + 5, 60]] = p;
        }
        
        let notes = extract_notes(frames, onsets);
        
        // Should be one single note
        assert_eq!(notes.len(), 1, "Should be one continuous note despite dips");
        assert_eq!(notes[0].midi_note, 60 + 21);
        
        let frame_duration = 512.0 / 22050.0;
        assert!((notes[0].duration - 7.0 * frame_duration).abs() < 1e-4);
    }
}