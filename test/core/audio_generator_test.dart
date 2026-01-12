
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/core/utils/audio_generator.dart';
import 'dart:math';

void main() {
  group('AudioGenerator', () {
    test('midiToFreq converts correctly', () {
      expect(AudioGenerator.midiToFreq(69), closeTo(440.0, 0.01)); // A4
      expect(AudioGenerator.midiToFreq(60), closeTo(261.63, 0.01)); // C4
    });

    test('generateSineWave produces correct samples', () {
      const sampleRate = 44100;
      const freq = 440.0;
      const duration = 1.0;
      final samples = AudioGenerator.generateSineWave(
        frequency: freq,
        duration: duration,
        sampleRate: sampleRate,
      );

      expect(samples.length, equals(sampleRate));
      // Check first few samples
      expect(samples[0], closeTo(0.0, 0.0001));
      expect(samples[1], closeTo(sin(2 * pi * freq * 1 / sampleRate), 0.0001));
    });
    
    test('generateNoteSequence supports overlapping notes', () {
       // This will be a higher level test for the sequence builder
       // For now, we just want to ensure we can sum signals
       final signal1 = [0.1, 0.2, 0.3];
       final signal2 = [0.2, 0.1, 0.0];
       final mixed = AudioGenerator.mix([signal1, signal2]);
       
       expect(mixed.length, 3);
       expect(mixed[0], closeTo(0.3, 0.0001));
       expect(mixed[1], closeTo(0.3, 0.0001));
       expect(mixed[2], closeTo(0.3, 0.0001));
    });

    test('saveToWav generates valid header', () async {
      final samples = [0.0, 0.5, -0.5, 0.0];
      final wavData = AudioGenerator.encodeWav(samples, sampleRate: 44100);
      
      // Check RIFF header
      expect(String.fromCharCodes(wavData.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wavData.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(wavData.sublist(12, 16)), 'fmt ');
      
      // Check data chunk
      // The location of 'data' depends on header size, usually 36 for standard PCM
      expect(String.fromCharCodes(wavData.sublist(36, 40)), 'data');
    });
  });
}
