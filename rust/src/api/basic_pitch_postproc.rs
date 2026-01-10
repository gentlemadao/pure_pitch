use ndarray::Array3;
use crate::api::pitch::NoteEvent;

pub fn extract_notes(frames: Array3<f32>, _onsets: Array3<f32>) -> Vec<NoteEvent> {
    let threshold = 0.3;
    let min_duration_frames = 3;
    let hop_length = 512.0;
    let sample_rate = 22050.0;
    let frame_duration = hop_length / sample_rate;

    let mut events = Vec::new();
    let n_frames = frames.shape()[1];
    let n_bins = frames.shape()[2];

    // Simple per-bin state tracking
    // active_notes[bin] = Some(start_frame)
    let mut active_notes: Vec<Option<usize>> = vec![None; n_bins];

    for t in 0..n_frames {
        for f in 0..n_bins {
            let prob = frames[[0, t, f]];
            
            if prob > threshold {
                if active_notes[f].is_none() {
                    active_notes[f] = Some(t);
                }
            } else {
                if let Some(start_frame) = active_notes[f] {
                    let duration_frames = t - start_frame;
                    if duration_frames >= min_duration_frames {
                        events.push(NoteEvent {
                            start_time: start_frame as f64 * frame_duration,
                            duration: duration_frames as f64 * frame_duration,
                            midi_note: (f + 21) as i32,
                        });
                    }
                    active_notes[f] = None;
                }
            }
        }
    }
    
    // Close pending notes
    for f in 0..n_bins {
        if let Some(start_frame) = active_notes[f] {
            let duration_frames = n_frames - start_frame;
            if duration_frames >= min_duration_frames {
                events.push(NoteEvent {
                    start_time: start_frame as f64 * frame_duration,
                    duration: duration_frames as f64 * frame_duration,
                    midi_note: (f + 21) as i32,
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
}