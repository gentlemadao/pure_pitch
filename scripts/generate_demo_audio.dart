// ignore_for_file: avoid_print
import 'dart:io';
import 'package:pure_pitch/core/utils/audio_generator.dart';

void main() async {
  final outputDir = Directory('temp');
  if (!outputDir.existsSync()) {
    outputDir.createSync();
  }

  // 1. A4 Sine Wave (440Hz)
  final a4Samples = AudioGenerator.generateSineWave(
    frequency: 440.0,
    duration: 3.0,
    sampleRate: 44100,
  );
  File(
    '${outputDir.path}/sine_a4_440hz.wav',
  ).writeAsBytesSync(AudioGenerator.encodeWav(a4Samples));
  print('Generated: sine_a4_440hz.wav');

  // 2. C Major Scale (Sawtooth)
  // Scale: C4, D4, E4, F4, G4, A4, B4, C5
  final scaleNotes = [60, 62, 64, 65, 67, 69, 71, 72];
  final scaleSamples = <double>[];
  final silence = List<double>.filled(4410, 0.0); // 0.1s silence

  for (final note in scaleNotes) {
    final freq = AudioGenerator.midiToFreq(note);
    final noteSamples = AudioGenerator.generateSawtoothWave(
      frequency: freq,
      duration: 0.5,
      sampleRate: 44100,
    ).map((s) => s * 0.5).toList(); // Lower volume

    scaleSamples.addAll(noteSamples);
    scaleSamples.addAll(silence);
  }

  File(
    '${outputDir.path}/scale_c_major_saw.wav',
  ).writeAsBytesSync(AudioGenerator.encodeWav(scaleSamples));
  print('Generated: scale_c_major_saw.wav');

  // 3. C Major Triad (Chord)
  // C4, E4, G4
  final chordNotes = [60, 64, 67];
  final signals = <List<double>>[];

  for (final note in chordNotes) {
    final freq = AudioGenerator.midiToFreq(note);
    final samples = AudioGenerator.generateSawtoothWave(
      frequency: freq,
      duration: 3.0,
      sampleRate: 44100,
    ).map((s) => s * 0.3).toList();
    signals.add(samples);
  }

  final chordSamples = AudioGenerator.mix(signals);
  File(
    '${outputDir.path}/chord_c_major.wav',
  ).writeAsBytesSync(AudioGenerator.encodeWav(chordSamples));
  print('Generated: chord_c_major.wav');
}
