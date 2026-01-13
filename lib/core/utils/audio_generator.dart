// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:math';
import 'dart:typed_data';

class AudioGenerator {
  /// Converts a MIDI note number to frequency in Hz.
  /// Formula: f = 440 * 2^((d - 69) / 12)
  static double midiToFreq(int midiNote) {
    return 440.0 * pow(2.0, (midiNote - 69) / 12.0);
  }

  /// Generates a sine wave.
  static List<double> generateSineWave({
    required double frequency,
    required double duration, // in seconds
    int sampleRate = 44100,
  }) {
    final int numSamples = (duration * sampleRate).toInt();
    final List<double> samples = List<double>.filled(numSamples, 0.0);
    
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      samples[i] = sin(2 * pi * frequency * t);
    }
    
    return samples;
  }

  /// Generates a sawtooth wave.
  static List<double> generateSawtoothWave({
    required double frequency,
    required double duration, // in seconds
    int sampleRate = 44100,
  }) {
    final int numSamples = (duration * sampleRate).toInt();
    final List<double> samples = List<double>.filled(numSamples, 0.0);
    
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Sawtooth formula: 2 * (t * f - floor(0.5 + t * f))
      double p = t * frequency;
      samples[i] = 2.0 * (p - (p + 0.5).floor());
    }
    
    return samples;
  }
  
  /// Mixes multiple signals together by summing them.
  /// Normalizes the output if it exceeds [-1.0, 1.0].
  static List<double> mix(List<List<double>> signals) {
    if (signals.isEmpty) return [];
    
    int maxLength = 0;
    for (final signal in signals) {
      if (signal.length > maxLength) maxLength = signal.length;
    }
    
    final List<double> mixed = List<double>.filled(maxLength, 0.0);
    
    for (int i = 0; i < maxLength; i++) {
      double sum = 0.0;
      for (final signal in signals) {
        if (i < signal.length) {
          sum += signal[i];
        }
      }
      mixed[i] = sum;
    }
    
    return mixed;
  }

  /// Encodes a list of samples (float -1.0 to 1.0) into a 16-bit PCM WAV byte buffer.
  static Uint8List encodeWav(List<double> samples, {int sampleRate = 44100}) {
    final int numChannels = 1;
    final int bitDepth = 16;
    final int byteRate = sampleRate * numChannels * bitDepth ~/ 8;
    final int blockAlign = numChannels * bitDepth ~/ 8;
    final int dataSize = samples.length * blockAlign;
    final int fileSize = 36 + dataSize;

    final buffer = ByteData(fileSize + 8);
    int offset = 0;

    // RIFF chunk
    _writeString(buffer, offset, 'RIFF'); offset += 4;
    buffer.setUint32(offset, fileSize, Endian.little); offset += 4;
    _writeString(buffer, offset, 'WAVE'); offset += 4;

    // fmt chunk
    _writeString(buffer, offset, 'fmt '); offset += 4;
    buffer.setUint32(offset, 16, Endian.little); offset += 4; // Subchunk1Size (16 for PCM)
    buffer.setUint16(offset, 1, Endian.little); offset += 2; // AudioFormat (1 for PCM)
    buffer.setUint16(offset, numChannels, Endian.little); offset += 2; // NumChannels
    buffer.setUint32(offset, sampleRate, Endian.little); offset += 4; // SampleRate
    buffer.setUint32(offset, byteRate, Endian.little); offset += 4; // ByteRate
    buffer.setUint16(offset, blockAlign, Endian.little); offset += 2; // BlockAlign
    buffer.setUint16(offset, bitDepth, Endian.little); offset += 2; // BitsPerSample

    // data chunk
    _writeString(buffer, offset, 'data'); offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little); offset += 4;

    // Write samples
    final maxAmplitude = 32767;
    for (final sample in samples) {
      // Clamp and scale
      final clamped = sample.clamp(-1.0, 1.0);
      final pcm = (clamped * maxAmplitude).round();
      buffer.setInt16(offset, pcm, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeString(ByteData buffer, int offset, String text) {
    for (int i = 0; i < text.length; i++) {
      buffer.setUint8(offset + i, text.codeUnitAt(i));
    }
  }
}
