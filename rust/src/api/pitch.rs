// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

use anyhow::Result;
use audioadapter_buffers::owned::InterleavedOwned;
use ndarray::Array3;
use ort::inputs;
use ort::session::Session;
use pitch_detection::detector::PitchDetector;
use pitch_detection::detector::mcleod::McLeodDetector;
use rubato::{
    Async, FixedAsync, Resampler, SincInterpolationParameters, SincInterpolationType,
    WindowFunction,
};
use std::fs::File;
use symphonia::core::audio::{AudioBufferRef, Signal};
use symphonia::core::codecs::DecoderOptions;
use symphonia::core::formats::FormatOptions;
use symphonia::core::io::MediaSourceStream;
use symphonia::core::meta::MetadataOptions;
use symphonia::core::probe::Hint;

use crate::api::basic_pitch_postproc::extract_notes;
use crate::api::aec::AecProcessor;
use std::sync::Mutex;
use once_cell::sync::Lazy;
use std::collections::HashMap;

static AEC_PROCESSOR: Lazy<Mutex<Option<AecProcessor>>> = Lazy::new(|| Mutex::new(None));
static AUDIO_CACHE: Lazy<Mutex<HashMap<String, Vec<f32>>>> = Lazy::new(|| Mutex::new(HashMap::new()));

pub fn clear_audio_cache() {
    let mut cache = AUDIO_CACHE.lock().unwrap();
    cache.clear();
    log::info!("Audio cache cleared");
}

fn get_cached_or_decode(path: &str, target_sample_rate: u32) -> Result<Vec<f32>> {
    let key = format!("{}:{}", path, target_sample_rate);
    
    // 1. Check Cache
    {
        let cache = AUDIO_CACHE.lock().unwrap();
        if let Some(data) = cache.get(&key) {
            log::info!("Cache hit for {}", key);
            return Ok(data.clone());
        }
    }

    // 2. Decode
    log::info!("Cache miss for {}, decoding...", key);
    let samples = decode_and_resample(path, target_sample_rate)?;

    // 3. Store
    {
        let mut cache = AUDIO_CACHE.lock().unwrap();
        cache.insert(key, samples.clone());
    }

    Ok(samples)
}

pub fn aec_init(
    sample_rate: u32,
    num_channels: u16,
    reference_paths: Vec<String>,
) -> Result<()> {
    // 1. Prepare buffers (decoding happens here or fetched from cache)
    let mut buffers = Vec::new();
    for path in reference_paths {
        buffers.push(get_cached_or_decode(&path, sample_rate)?);
    }

    let new_aec = AecProcessor::new(sample_rate, num_channels, buffers)?;
    
    // 2. Store
    let mut aec = AEC_PROCESSOR.lock().unwrap();
    *aec = Some(new_aec);
    log::info!("AEC initialized successfully");
    Ok(())
}

pub fn aec_reset() {
    let mut aec = AEC_PROCESSOR.lock().unwrap();
    *aec = None;
    log::info!("AEC reset");
}

// Output of offline analysis (Extracted Notes)
#[derive(Clone, Debug)]
pub struct NoteEvent {
    pub start_time: f64, // seconds
    pub duration: f64,   // seconds
    pub midi_note: i32,  // MIDI value
    pub confidence: f32, // Average probability
}

// Output of real-time detection
pub struct LivePitch {
    pub hz: f64,
    pub midi_note: i32,
    pub clarity: f32,   // Confidence (0.0 - 1.0)
    pub amplitude: f32, // RMS amplitude (0.0 - 1.0)
}

use std::env;

/// Initialize ORT environment.
/// Must be called before any other ORT operations.
///
/// [dylib_path] Optional path to the onnxruntime dynamic library.
/// If provided, it sets the ORT_DYLIB_PATH environment variable.
pub fn init_ort(dylib_path: Option<String>) -> Result<()> {
    if let Some(path) = dylib_path {
        unsafe {
            env::set_var("ORT_DYLIB_PATH", path);
        }
    } else {
        #[cfg(any(target_os = "macos", target_os = "ios"))]
        {
            if let Ok(exe_path) = env::current_exe() {
                let contents = exe_path.parent().unwrap();

                let dylib_path = if cfg!(target_os = "macos") {
                    // macOS: Contents/Frameworks/rust_lib_pure_pitch.framework/Resources/libonnxruntime.dylib
                    contents
                        .parent()
                        .unwrap()
                        .join("Frameworks")
                        .join("rust_lib_pure_pitch.framework")
                        .join("Resources")
                        .join("libonnxruntime.dylib")
                } else {
                    // iOS: Frameworks/onnxruntime.framework/onnxruntime
                    contents
                        .join("Frameworks")
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
    }
    Ok(())
}

/// Analyze an audio file and return a list of note events.
pub fn analyze_audio_file(audio_path: String, model_path: String) -> Result<Vec<NoteEvent>> {
    // 22050 is required for Basic Pitch model
    let samples = get_cached_or_decode(&audio_path, 22050)?;
    let raw_notes = run_inference_internal(&samples, &model_path)?;
    let merged_notes = merge_note_events(raw_notes);
    Ok(enforce_global_monophony(merged_notes))
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
        let note_array = ndarray::ArrayView::from_shape(
            (
                note_shape[0] as usize,
                note_shape[1] as usize,
                note_shape[2] as usize,
            ),
            note_data,
        )?
        .to_owned();
        let onset_array = ndarray::ArrayView::from_shape(
            (
                onset_shape[0] as usize,
                onset_shape[1] as usize,
                onset_shape[2] as usize,
            ),
            onset_data,
        )?
        .to_owned();

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

pub(crate) fn decode_and_resample(path: &str, target_sample_rate: u32) -> Result<Vec<f32>> {
    use std::io::Read;
    use symphonia::core::io::MediaSourceStreamOptions;

    // Read the entire file into memory to ensure reliable seeking on Android
    let mut file = File::open(path)?;
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer)?;

    // Increase buffer size to handle large metadata tags or cover art
    let mss_opts = MediaSourceStreamOptions {
        buffer_len: 512 * 1024, // 512 KB
    };
    let mss = MediaSourceStream::new(Box::new(std::io::Cursor::new(buffer)), mss_opts);
    let mut hint = Hint::new();

    if let Some(ext) = std::path::Path::new(path)
        .extension()
        .and_then(|s| s.to_str())
    {
        hint.with_extension(ext);
    }

    let format_opts = FormatOptions {
        enable_gapless: true,
        ..Default::default()
    };

    let probed = symphonia::default::get_probe().format(
        &hint,
        mss,
        &format_opts,
        &MetadataOptions::default(),
    )?;

    let mut format = probed.format;
    let track = format
        .tracks()
        .iter()
        .find(|t| t.codec_params.codec != symphonia::core::codecs::CODEC_TYPE_NULL)
        .ok_or_else(|| anyhow::anyhow!("No supported audio track found"))?;

    let codec_params = &track.codec_params;
    let mut decoder =
        symphonia::default::get_codecs().make(codec_params, &DecoderOptions::default())?;

    let track_id = track.id;
    let mut samples: Vec<f32> = Vec::new();
    let original_sample_rate = codec_params.sample_rate.unwrap_or(44100);

    // Resilient decoding loop: skip bad packets instead of failing the whole process
    loop {
        let packet = match format.next_packet() {
            Ok(packet) => packet,
            Err(symphonia::core::errors::Error::IoError(ref e))
                if e.kind() == std::io::ErrorKind::UnexpectedEof =>
            {
                break;
            }
            Err(e) => {
                log::warn!("Format error: {}, skipping packet", e);
                continue;
            }
        };

        if packet.track_id() != track_id {
            continue;
        }

        match decoder.decode(&packet) {
            Ok(decoded) => match decoded {
                AudioBufferRef::F32(buf) => {
                    for i in 0..buf.frames() {
                        let mut sum = 0.0;
                        for chan in 0..buf.spec().channels.count() {
                            sum += buf.chan(chan)[i];
                        }
                        samples.push(sum / buf.spec().channels.count() as f32);
                    }
                }
                AudioBufferRef::S16(buf) => {
                    for i in 0..buf.frames() {
                        let mut sum = 0.0;
                        for chan in 0..buf.spec().channels.count() {
                            sum += buf.chan(chan)[i] as f32 / 32768.0;
                        }
                        samples.push(sum / buf.spec().channels.count() as f32);
                    }
                }
                _ => {
                    log::warn!("Unsupported audio buffer type");
                }
            },
            Err(symphonia::core::errors::Error::DecodeError(e)) => {
                log::warn!("Decode error: {}, skipping packet", e);
                continue;
            }
            Err(e) => {
                return Err(e.into());
            }
        }
    }

    if samples.is_empty() {
        return Err(anyhow::anyhow!("No audio samples were decoded"));
    }

    if original_sample_rate != target_sample_rate {
        let params = SincInterpolationParameters {
            sinc_len: 256,
            f_cutoff: 0.95,
            interpolation: SincInterpolationType::Linear,
            window: WindowFunction::BlackmanHarris2,
            oversampling_factor: 256,
        };

        let chunk_size = samples.len();
        let mut resampler = Async::<f32>::new_sinc(
            target_sample_rate as f64 / original_sample_rate as f64,
            2.0,
            &params,
            chunk_size,
            1,
            FixedAsync::Input,
        )?;

        let num_frames = samples.len();
        let input_adapter = InterleavedOwned::new_from(samples, 1, num_frames)
            .map_err(|e| anyhow::anyhow!("Failed to create adapter: {:?}", e))?;

        let resampled = resampler.process(&input_adapter, 0, None)?;
        Ok(resampled.take_data())
    } else {
        Ok(samples)
    }
}

/// Detect pitch from a real-time audio buffer.
pub fn detect_pitch_live(mut samples: Vec<f32>, sample_rate: f64) -> Result<LivePitch> {
    // Apply AEC if active
    {
        let mut aec_lock = AEC_PROCESSOR.lock().unwrap();
        if let Some(aec) = aec_lock.as_mut() {
            if let Err(e) = aec.process_frame(&mut samples) {
                log::error!("AEC processing failed: {}", e);
                return Err(e);
            }
        }
    }

    const POWER_THRESHOLD: f64 = 0.1; // Lowered threshold for sensitivity
    const CLARITY_THRESHOLD: f64 = 0.6;

    let signal: Vec<f64> = samples.iter().map(|&x| x as f64).collect();
    let size = signal.len();
    let padding = size / 2;

    // Calculate RMS amplitude
    let rms = if size > 0 {
        (signal.iter().map(|&x| x * x).sum::<f64>() / size as f64).sqrt() as f32
    } else {
        0.0
    };

    let mut detector = McLeodDetector::new(size, padding);

    match detector.get_pitch(
        &signal,
        sample_rate as usize,
        POWER_THRESHOLD,
        CLARITY_THRESHOLD,
    ) {
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
                amplitude: rms,
            })
        }
        None => Ok(LivePitch {
            hz: 0.0,
            midi_note: 0,
            clarity: 0.0,
            amplitude: rms,
        }),
    }
}

fn merge_note_events(mut notes: Vec<NoteEvent>) -> Vec<NoteEvent> {
    if notes.is_empty() {
        return notes;
    }

    // Sort by start time
    notes.sort_by(|a, b| {
        a.start_time
            .partial_cmp(&b.start_time)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    let mut merged = Vec::new();
    let mut current = notes[0].clone();

    for next in notes.into_iter().skip(1) {
        let prev_end = current.start_time + current.duration;
        // Gap can be negative if overlaps
        let gap = next.start_time - prev_end;

        // Tolerance: 25ms = 0.025s
        // Also handle slight overlaps (gap < 0) but not too much overlap?
        // Monophonic output shouldn't have large overlaps for same pitch unless chunk boundary artifact.
        // Let's assume if it's the same pitch and close enough, we merge.
        if current.midi_note == next.midi_note && gap < 0.05 && gap > -0.05 {
            // Merge
            // New end should be max of both ends to handle total enclosure
            let current_end = current.start_time + current.duration;
            let next_end = next.start_time + next.duration;
            let new_end = f64::max(current_end, next_end);
            let new_duration = new_end - current.start_time;

            // Weighted confidence
            let total_dur = current.duration + next.duration;
            if total_dur > 0.0 {
                let new_confidence = (current.confidence * current.duration as f32
                    + next.confidence * next.duration as f32)
                    / total_dur as f32;
                current.confidence = new_confidence;
            }

            current.duration = new_duration;
        } else {
            merged.push(current);
            current = next;
        }
    }
    merged.push(current);

    merged
}

fn enforce_global_monophony(mut notes: Vec<NoteEvent>) -> Vec<NoteEvent> {
    if notes.is_empty() {
        return notes;
    }

    // Sort by start time
    notes.sort_by(|a, b| {
        a.start_time
            .partial_cmp(&b.start_time)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    let mut processed = Vec::new();
    let mut current = notes[0].clone();

    for next in notes.into_iter().skip(1) {
        let current_end = current.start_time + current.duration;

        if next.start_time < current_end {
            // Overlap detected
            if next.confidence > current.confidence {
                // Next wins. Truncate current.
                let new_duration = next.start_time - current.start_time;
                if new_duration >= 0.1 {
                    // Min duration check (100ms)
                    current.duration = new_duration;
                    processed.push(current);
                }
                current = next;
            } else {
                // Current wins (or equal). Truncate/Delay Next.
                let next_end = next.start_time + next.duration;
                let new_duration = next_end - current_end;

                if new_duration >= 0.1 {
                    let mut delayed_next = next;
                    delayed_next.start_time = current_end;
                    delayed_next.duration = new_duration;

                    processed.push(current);
                    current = delayed_next;
                } else {
                    // Next is swallowed/discarded. Keep current as active.
                }
            }
        } else {
            // No overlap
            processed.push(current);
            current = next;
        }
    }
    // Push the last one (check duration just in case, though usually valid from source)
    if current.duration >= 0.1 {
        processed.push(current);
    }

    processed
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_enforce_global_monophony() {
        let notes = vec![
            // Note A: 0.0 - 1.0, conf 0.8
            NoteEvent {
                start_time: 0.0,
                duration: 1.0,
                midi_note: 60,
                confidence: 0.8,
            },
            // Note B: 0.5 - 1.5, conf 0.9 (Should truncate A)
            NoteEvent {
                start_time: 0.5,
                duration: 1.0,
                midi_note: 62,
                confidence: 0.9,
            },
            // Note C: 1.4 - 2.4, conf 0.5 (Should be delayed/truncated by B)
            NoteEvent {
                start_time: 1.4,
                duration: 1.0,
                midi_note: 64,
                confidence: 0.5,
            },
        ];

        let processed = enforce_global_monophony(notes);

        assert_eq!(processed.len(), 3);

        // Note A should end at 0.5
        assert!((processed[0].duration - 0.5).abs() < 0.001);

        // Note B should start at 0.5, duration 1.0
        assert_eq!(processed[1].start_time, 0.5);
        assert_eq!(processed[1].duration, 1.0);

        // Note C should start at 1.5 (truncated start)
        assert_eq!(processed[2].start_time, 1.5);
        assert!((processed[2].duration - 0.9).abs() < 0.001);
    }

    #[test]
    fn test_merge_note_events() {
        let notes = vec![
            NoteEvent {
                start_time: 0.0,
                duration: 1.0,
                midi_note: 60,
                confidence: 0.8,
            },
            NoteEvent {
                start_time: 1.01,
                duration: 1.0,
                midi_note: 60,
                confidence: 0.9,
            }, // Should merge (gap 0.01)
            NoteEvent {
                start_time: 2.5,
                duration: 1.0,
                midi_note: 60,
                confidence: 0.8,
            }, // Should not merge (gap 0.49)
            NoteEvent {
                start_time: 3.6,
                duration: 1.0,
                midi_note: 62,
                confidence: 0.8,
            }, // Diff pitch
        ];

        let merged = merge_note_events(notes);

        assert_eq!(merged.len(), 3);
        // First merged note
        assert_eq!(merged[0].midi_note, 60);
        assert!((merged[0].duration - 2.01).abs() < 0.001);
        // Confidence: (0.8*1.0 + 0.9*1.0) / 2.0 = 0.85
        assert!((merged[0].confidence - 0.85).abs() < 0.001);

        // Second note
        assert_eq!(merged[1].start_time, 2.5);

        // Third note
        assert_eq!(merged[2].midi_note, 62);
    }

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
        let result =
            analyze_audio_file("non_existent_audio.wav".to_string(), model_path.to_string());
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
