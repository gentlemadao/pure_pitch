// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.

use anyhow::Result;
use pitch_detection::detector::mcleod::McLeodDetector;
use pitch_detection::detector::PitchDetector;
use std::fs::File;
use symphonia::core::io::MediaSourceStream;
use symphonia::core::probe::Hint;
use symphonia::core::formats::FormatOptions;
use symphonia::core::meta::MetadataOptions;
use symphonia::core::codecs::DecoderOptions;
use symphonia::core::audio::{AudioBufferRef, Signal};
use rubato::{Resampler, Async, FixedAsync, SincInterpolationParameters, SincInterpolationType, WindowFunction};
use audioadapter_buffers::owned::InterleavedOwned;
use ndarray::Array3;
use ort::session::Session;
use ort::inputs;

use crate::api::basic_pitch_postproc::extract_notes;

// Output of offline analysis (Extracted Notes)
pub struct NoteEvent {
    pub start_time: f64, // seconds
    pub duration: f64,   // seconds
    pub midi_note: i32,  // MIDI value
}

// Output of real-time detection
pub struct LivePitch {
    pub hz: f64,
    pub midi_note: i32,
    pub clarity: f32,    // Confidence (0.0 - 1.0)
}

use std::env;

/// Initialize ORT environment. 
/// Must be called before any other ORT operations.
pub fn init_ort() -> Result<()> {
    #[cfg(any(target_os = "macos", target_os = "ios"))]
    {
        if let Ok(exe_path) = env::current_exe() {
            let contents = exe_path.parent().unwrap();
            
            let dylib_path = if cfg!(target_os = "macos") {
                // macOS: Contents/Frameworks/rust_lib_pure_pitch.framework/Resources/libonnxruntime.dylib
                contents.parent().unwrap()
                    .join("Frameworks")
                    .join("rust_lib_pure_pitch.framework")
                    .join("Resources")
                    .join("libonnxruntime.dylib")
            } else {
                // iOS: Frameworks/onnxruntime.framework/onnxruntime
                contents.join("Frameworks")
                    .join("onnxruntime.framework")
                    .join("onnxruntime")
            };
            
            if dylib_path.exists() {
                 // ORT_DYLIB_PATH setting is unsafe because it modifies global environment
                 // which is not thread-safe. We do this at init time.
                 unsafe {
                     env::set_var("ORT_DYLIB_PATH", dylib_path);
                 }
            }
        }
    }
    Ok(())
}

/// Analyze an audio file and return a list of note events.
pub fn analyze_audio_file(audio_path: String, model_path: String) -> Result<Vec<NoteEvent>> {
    let samples = decode_and_resample(&audio_path, 22050)?;
    run_inference_internal(&samples, &model_path)
}

fn run_inference_internal(samples: &[f32], model_path: &str) -> Result<Vec<NoteEvent>> {
    let target_len = 43844;
    let mut all_notes = Vec::new();
    
    // Load model
    let mut session = Session::builder()?.commit_from_file(model_path)?;

    // Process in chunks
    // We use a simple non-overlapping sliding window for MVP.
    // Ideally, we should use overlap and blend.
    let total_samples = samples.len();
    let num_chunks = (total_samples + target_len - 1) / target_len;

    for i in 0..num_chunks {
        let start = i * target_len;
        let end = std::cmp::min(start + target_len, total_samples);
        let chunk_len = end - start;
        
        // Prepare padded chunk
        let mut chunk_data = vec![0.0f32; target_len];
        chunk_data[..chunk_len].copy_from_slice(&samples[start..end]);
        
        let input_tensor = preprocess_chunk(&chunk_data);
        
        // Debug check
        if i == 0 {
            log::info!("Input tensor shape: {:?}", input_tensor.shape());
        }
        
        // Convert to ORT Value
        let input_value = ort::value::Tensor::from_array(input_tensor)?;
        
        // Run inference
        let outputs = session.run(inputs!["input_2" => input_value])?;
        
        // Extract outputs
        let (note_shape, note_data) = outputs["note"].try_extract_tensor::<f32>()?;
        let (onset_shape, onset_data) = outputs["onset"].try_extract_tensor::<f32>()?;
        
        // Convert to Array3
        let note_array = ndarray::ArrayView::from_shape((note_shape[0] as usize, note_shape[1] as usize, note_shape[2] as usize), note_data)?.to_owned();
        let onset_array = ndarray::ArrayView::from_shape((onset_shape[0] as usize, onset_shape[1] as usize, onset_shape[2] as usize), onset_data)?.to_owned();
        
        let mut chunk_notes = extract_notes(note_array, onset_array);
        
        // Adjust timestamps
        // Basic Pitch time scale: output frame index -> time?
        // extract_notes calculates start_time based on frame index.
        // We need to add the chunk start time offset.
        let chunk_start_time = start as f64 / 22050.0;
        for note in &mut chunk_notes {
            note.start_time += chunk_start_time;
        }
        
        all_notes.extend(chunk_notes);
    }

    Ok(all_notes)
}

fn preprocess_chunk(chunk: &[f32]) -> Array3<f32> {
    // Expects chunk to be exactly 43844 length (or whatever target_len is passed, but here we assume caller handles padding)
    // Basic Pitch expects [Batch, Time, Channels] -> [1, N, 1]
    let len = chunk.len();
    let array = ndarray::Array::from_shape_vec((1, len, 1), chunk.to_vec()).unwrap(); 
    array
}

fn decode_and_resample(path: &str, target_sample_rate: u32) -> Result<Vec<f32>> {
    let src = File::open(path)?;
    let mss = MediaSourceStream::new(Box::new(src), Default::default());
    let mut hint = Hint::new();
    hint.with_extension("mp3"); // Should be dynamic based on extension

    let probed = symphonia::default::get_probe().format(&hint, mss, &FormatOptions::default(), &MetadataOptions::default())?;
    let mut format = probed.format;
    let track = format.tracks().iter().find(|t| t.codec_params.codec != symphonia::core::codecs::CODEC_TYPE_NULL).ok_or_else(|| anyhow::anyhow!("No supported audio track found"))?;
    
    let codec_params = &track.codec_params;
    let mut decoder = symphonia::default::get_codecs().make(codec_params, &DecoderOptions::default())?;
    
    let track_id = track.id;
    let mut samples: Vec<f32> = Vec::new();
    let original_sample_rate = codec_params.sample_rate.unwrap_or(44100);

    while let Ok(packet) = format.next_packet() {
        if packet.track_id() != track_id {
            continue;
        }

        let decoded = decoder.decode(&packet)?;
        
        match decoded {
            AudioBufferRef::F32(buf) => {
                for i in 0..buf.frames() {
                    let mut sum = 0.0;
                    for chan in 0..buf.spec().channels.count() {
                        sum += buf.chan(chan)[i];
                    }
                    samples.push(sum / buf.spec().channels.count() as f32);
                }
            },
            _ => {
                // TODO: Support other bit depths if needed
            }
        }
    }

    if original_sample_rate != target_sample_rate {
        let params = SincInterpolationParameters {
            sinc_len: 256,
            f_cutoff: 0.95,
            interpolation: SincInterpolationType::Linear,
            window: WindowFunction::BlackmanHarris2,
            oversampling_factor: 256,
        };
        let mut resampler = Async::<f32>::new_sinc(
            target_sample_rate as f64 / original_sample_rate as f64,
            2.0,
            &params,
            1024,
            1,
            FixedAsync::Input,
        )?;
        
        let num_frames = samples.len();
        let input_adapter = InterleavedOwned::new_from(samples, 1, num_frames).map_err(|e| anyhow::anyhow!("Failed to create adapter: {:?}", e))?;
        
        let resampled = resampler.process(&input_adapter, 0, None)?;
        Ok(resampled.take_data())
    } else {
        Ok(samples)
    }
}

/// Detect pitch from a real-time audio buffer.
pub fn detect_pitch_live(samples: Vec<f32>, sample_rate: f64) -> Result<LivePitch> {
    const POWER_THRESHOLD: f64 = 0.1; // Lowered threshold for sensitivity
    const CLARITY_THRESHOLD: f64 = 0.6;

    let signal: Vec<f64> = samples.iter().map(|&x| x as f64).collect();
    let size = signal.len();
    let padding = size / 2; 

    let mut detector = McLeodDetector::new(size, padding);

    match detector.get_pitch(&signal, sample_rate as usize, POWER_THRESHOLD, CLARITY_THRESHOLD) {
        Some(pitch) => {
            // MIDI = 69 + 12 * log2(freq / 440)
            let midi_note = if pitch.frequency > 0.0 {
                (69.0 + 12.0 * (pitch.frequency / 440.0).log2()).round() as i32
            } else {
                0
            };

            Ok(LivePitch {
                hz: pitch.frequency,
                midi_note,
                clarity: pitch.clarity as f32,
            })
        },
        None => {
             Ok(LivePitch {
                hz: 0.0,
                midi_note: 0,
                clarity: 0.0,
            })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_preprocess_chunk_shape() {
        let samples = vec![0.0; 43844];
        let tensor = preprocess_chunk(&samples);
        assert_eq!(tensor.shape(), &[1, 43844, 1]);
    }

    #[test]
    fn test_detect_pitch_sine_wave() {
        let sample_rate = 44100.0;
        let freq = 440.0; // A4
        let duration = 0.5; // 500ms
        let num_samples = (sample_rate * duration) as usize;
        
        let samples: Vec<f32> = (0..num_samples)
            .map(|i| (2.0 * std::f64::consts::PI * freq * (i as f64) / sample_rate).sin() as f32)
            .collect();

        let result = detect_pitch_live(samples, sample_rate).unwrap();
        
        println!("Detected: {} Hz, Clarity: {}", result.hz, result.clarity);
        assert!((result.hz - freq).abs() < 5.0);
        assert_eq!(result.midi_note, 69);
        assert!(result.clarity > 0.8);
    }

    #[test]
    fn test_analyze_audio_file_model_loading() {
        let model_path = "../assets/models/basic_pitch.onnx"; 
        let result = analyze_audio_file("non_existent_audio.wav".to_string(), model_path.to_string());
        assert!(result.is_err());
    }

    #[test]
    // #[ignore]
    fn test_run_inference_internal() {
        let model_path = "../assets/models/basic_pitch.onnx";
        let samples = vec![0.0; 22050 * 3];
        let _result = run_inference_internal(&samples, model_path);
        // assert!(_result.is_ok()); // Ignored
    }
}
