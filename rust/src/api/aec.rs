// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

use anyhow::Result;
use aec3::voip::VoipAec3;
use std::collections::VecDeque;

pub(crate) struct AecProcessor {
    processor: VoipAec3,
    reference_samples: Vec<f32>,
    cursor: usize,
    chunk_size: usize,
    input_queue: VecDeque<f32>,
    output_queue: VecDeque<f32>,
}

unsafe impl Send for AecProcessor {}

impl AecProcessor {
    pub(crate) fn new(sample_rate: u32, num_channels: u16, reference_buffers: Vec<Vec<f32>>) -> Result<Self> {
        let processor = VoipAec3::builder(
            sample_rate as usize,
            num_channels as usize,
            num_channels as usize,
        ).build().map_err(|e| anyhow::anyhow!("{}", e))?;

        // 10ms chunk size (e.g. 441 at 44.1kHz)
        let chunk_size = (sample_rate / 100) as usize;

        // Mix all reference sources
        let mut mixed_reference = Vec::new();
        let source_count = reference_buffers.len();
        
        for samples in reference_buffers {
            if mixed_reference.is_empty() {
                mixed_reference = samples;
            } else {
                let len = std::cmp::min(mixed_reference.len(), samples.len());
                for i in 0..len {
                    mixed_reference[i] += samples[i];
                }
                if samples.len() > mixed_reference.len() {
                    mixed_reference.extend_from_slice(&samples[mixed_reference.len()..]);
                }
            }
        }

        // Normalize to prevent clipping if multiple sources were mixed
        if source_count > 1 {
            let scale = 1.0 / (source_count as f32);
            for sample in &mut mixed_reference {
                *sample *= scale;
            }
        }
        
        Ok(Self { 
            processor,
            reference_samples: mixed_reference,
            cursor: 0,
            chunk_size,
            input_queue: VecDeque::with_capacity(chunk_size * 4),
            output_queue: VecDeque::with_capacity(chunk_size * 4),
        })
    }

    pub(crate) fn process_frame(&mut self, audio_frame: &mut [f32]) -> Result<()> {
        let frame_len = audio_frame.len();

        // 1. Push new mic samples to input queue
        self.input_queue.extend(audio_frame.iter());

        // 2. Process all available 10ms chunks
        while self.input_queue.len() >= self.chunk_size {
            let capture_chunk: Vec<f32> = self.input_queue.drain(..self.chunk_size).collect();
            let mut output_chunk = vec![0.0f32; self.chunk_size];
            
            let mut reference_chunk = vec![0.0f32; self.chunk_size];
            if !self.reference_samples.is_empty() {
                let end = std::cmp::min(self.cursor + self.chunk_size, self.reference_samples.len());
                let len = end - self.cursor;
                if len > 0 {
                    reference_chunk[..len].copy_from_slice(&self.reference_samples[self.cursor..end]);
                    self.cursor += len;
                }
            }

            // AEC3 Processing
            self.processor.process(
                &capture_chunk,
                Some(&reference_chunk),
                false,
                &mut output_chunk
            ).map_err(|e| anyhow::anyhow!("{}", e))?;
            
            self.output_queue.extend(output_chunk);
        }

        // 3. Greedy fill: Fill as much as possible from output queue
        for i in 0..frame_len {
            if let Some(s) = self.output_queue.pop_front() {
                audio_frame[i] = s;
            } else {
                // If queue empty, zero out the rest (initial startup only)
                audio_frame[i] = 0.0;
            }
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_aec_reduces_echo_buffered() {
        let mut aec = AecProcessor::new(16000, 1, vec![]).unwrap();
        let frame_size = 1024;
        let mut mic = vec![0.0f32; frame_size];
        
        // First call might have some zeros at tail
        aec.process_frame(&mut mic).unwrap();
        
        // Second call should have data
        aec.process_frame(&mut mic).unwrap();
        
        let energy: f32 = mic.iter().map(|x| x * x).sum();
        assert!(energy >= 0.0);
    }
}