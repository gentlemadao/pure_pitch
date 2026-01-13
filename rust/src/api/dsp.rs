// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

use ndarray::Array2;

use rustfft::{FftPlanner, num_complex::Complex};



/// Performs a Short-Time Fourier Transform (STFT) on the input signal.

/// FFT Size = 2048, Hop Size = 512, Window = Hann.

#[flutter_rust_bridge::frb(ignore)]

pub fn stft(signal: &[f32], fft_size: usize, hop_size: usize) -> Array2<f32> {

    let mut planner = FftPlanner::new();

    let fft = planner.plan_fft_forward(fft_size);

    

    let window: Vec<f32> = (0..fft_size)

        .map(|i| 0.5 * (1.0 - (2.0 * std::f32::consts::PI * i as f32 / (fft_size - 1) as f32).cos()))

        .collect();



    let num_frames = if signal.len() >= fft_size {

        (signal.len() - fft_size) / hop_size + 1

    } else {

        0

    };

    

    let num_bins = fft_size / 2 + 1;

    let mut spectrogram = Array2::zeros((num_frames, num_bins));



    for frame_idx in 0..num_frames {

        let start = frame_idx * hop_size;

        let mut buffer: Vec<Complex<f32>> = (0..fft_size)

            .map(|i| {

                let sample = signal.get(start + i).copied().unwrap_or(0.0);

                Complex::new(sample * window[i], 0.0)

            })

            .collect();



        fft.process(&mut buffer);



        for bin_idx in 0..num_bins {

            spectrogram[[frame_idx, bin_idx]] = buffer[bin_idx].norm();

        }

    }



    spectrogram

}



/// Converts a magnitude spectrogram to a log-magnitude spectrogram.

#[flutter_rust_bridge::frb(ignore)]

pub fn log_magnitude(spectrogram: Array2<f32>) -> Array2<f32> {

    spectrogram.mapv(|x| (x + 1e-6).ln())

}



                

                #[cfg(test)]

                

        mod tests {

            use super::*;

        

            #[test]

            fn test_stft_basic() {

                let signal = vec![0.0; 4096];

                let fft_size = 2048;

                let hop_size = 512;

                let spectrogram = stft(&signal, fft_size, hop_size);

                

                assert_eq!(spectrogram.shape()[1], fft_size / 2 + 1);

                assert!(spectrogram.shape()[0] > 0);

            }

        }

        
