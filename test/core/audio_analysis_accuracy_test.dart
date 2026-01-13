// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';
import 'package:pure_pitch/core/utils/audio_generator.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

void main() async {
  setUpAll(() async {
    // Initialize Rust Library
    if (!RustLib.instance.initialized) {
      final String dylibPath;
      if (Platform.isMacOS) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.dylib';
      } else if (Platform.isWindows) {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/rust_lib_pure_pitch.dll';
      } else {
        dylibPath =
            '${Directory.current.path}/rust/target/debug/librust_lib_pure_pitch.so';
      }

      developer.log('Loading rust library from: $dylibPath');
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    }

    // Initialize ORT
    // We explicitly point to the libonnxruntime.dylib in target/debug
    String? ortDylibPath;
    if (Platform.isMacOS) {
      ortDylibPath =
          '${Directory.current.path}/rust/target/debug/libonnxruntime.dylib';
    } else if (Platform.isLinux) {
      // On Linux CI, it might be in target/debug or target/debug/deps or deep in build/
      final possiblePaths = [
        '${Directory.current.path}/rust/target/debug/libonnxruntime.so',
        '${Directory.current.path}/rust/target/debug/deps/libonnxruntime.so',
      ];

      for (final path in possiblePaths) {
        if (File(path).existsSync()) {
          ortDylibPath = path;
          break;
        }
      }
    }

    try {
      await initOrt(dylibPath: ortDylibPath);
    } catch (e) {
      developer.log(
        'Warning: initOrt failed (expected if already initialized or env not set): $e',
      );
    }
  });

  test('environment sanity check', () {
    final modelPath =
        '${Directory.current.path}/assets/models/basic_pitch.onnx';
    expect(
      File(modelPath).existsSync(),
      isTrue,
      reason: 'Model file must exist for tests to run',
    );
  });

  test('accuracy test: simple sawtooth wave (A4 = 440Hz)', () async {
    // 1. Generate Audio with silence padding
    final silence = List<double>.filled((0.2 * 22050).toInt(), 0.0);
    final note = AudioGenerator.generateSawtoothWave(
      frequency: 440.0,
      duration: 1.0,
      sampleRate: 22050,
    ).map((s) => s * 0.5).toList();

    final samples = [...silence, ...note, ...silence];

    final bytes = AudioGenerator.encodeWav(samples, sampleRate: 22050);
    final tempFile = File('${Directory.systemTemp.path}/test_a4.wav');
    await tempFile.writeAsBytes(bytes);

    // 2. Analyze
    final modelPath =
        '${Directory.current.path}/assets/models/basic_pitch.onnx';
    final notes = await analyzeAudioFile(
      audioPath: tempFile.path,
      modelPath: modelPath,
    );

    // 3. Verify
    // Basic Pitch might not be perfect with pure sine waves (it's trained on real instruments),
    // but it should detect something close.
    // However, Basic Pitch often struggles with pure sine waves as they lack harmonics.
    // Let's see what happens.

    developer.log('Detected notes: $notes');
    final f1 = AccuracyMetrics.calculateF1Score([69], notes);
    developer.log('Sawtooth A4 F1 Score: $f1');

    expect(notes, isNotEmpty);
    // Allow some tolerance or multiple detections if it splits the note
    final matchingNotes = notes
        .where((n) => (n.midiNote - 69).abs() <= 1)
        .toList();
    expect(
      matchingNotes,
      isNotEmpty,
      reason: 'Should detect A4 (69) within +/- 1 semitone',
    );

    // Clean up
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  test('accuracy test: C Major Scale (C4 to C5)', () async {
    // 1. Generate Audio
    // Scale: C4, D4, E4, F4, G4, A4, B4, C5
    final notes = [60, 62, 64, 65, 67, 69, 71, 72];
    final samples = <double>[];

    // Silence padding
    final silence = List<double>.filled(4000, 0.0);

    for (final note in notes) {
      final freq = AudioGenerator.midiToFreq(note);
      final noteSamples = AudioGenerator.generateSawtoothWave(
        frequency: freq,
        duration: 0.5, // 0.5s per note
        sampleRate: 44100,
      ).map((s) => s * 0.5).toList();

      // Adjust silence length for 44100
      final silence = List<double>.filled(8000, 0.0);

      samples.addAll(silence);
      samples.addAll(noteSamples);
    }
    samples.addAll(silence);

    final bytes = AudioGenerator.encodeWav(samples, sampleRate: 44100);
    final tempFile = File('${Directory.systemTemp.path}/test_c_major.wav');
    await tempFile.writeAsBytes(bytes);

    // 2. Analyze
    final modelPath =
        '${Directory.current.path}/assets/models/basic_pitch.onnx';
    final detectedNotes = await analyzeAudioFile(
      audioPath: tempFile.path,
      modelPath: modelPath,
    );

    // 3. Verify
    developer.log('Detected notes count: ${detectedNotes.length}');
    for (var n in detectedNotes) {
      developer.log('Note: ${n.midiNote} at ${n.startTime}s');
    }

    final f1 = AccuracyMetrics.calculateF1Score(notes, detectedNotes);
    developer.log('C Major Scale F1 Score: $f1');

    // Check total duration
    if (detectedNotes.isNotEmpty) {
      final lastNote = detectedNotes.last;
      final analyzedDuration = lastNote.startTime + lastNote.duration;
      developer.log('Analyzed Duration: $analyzedDuration s');
      // The generated audio is roughly 8 * (0.5+0.1) = 4.8s + padding
      expect(
        analyzedDuration,
        greaterThan(4.0),
        reason: 'Analysis should cover most of the audio file',
      );
    }

    // We expect at least one detection for each played note
    for (final expectedMidi in notes) {
      final found = detectedNotes.any(
        (n) => (n.midiNote - expectedMidi).abs() <= 1,
      );
      expect(found, isTrue, reason: 'Expected to find MIDI note $expectedMidi');
    }

    // Clean up
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  test('accuracy test: C Major Triad (C4, E4, G4)', () async {
    // 1. Generate Audio: C4 (60), E4 (64), G4 (67)
    final chordNotes = [60, 64, 67];
    final signals = <List<double>>[];

    for (final note in chordNotes) {
      final freq = AudioGenerator.midiToFreq(note);
      final samples =
          AudioGenerator.generateSawtoothWave(
                frequency: freq,
                duration: 1.0,
                sampleRate: 22050,
              )
              .map((s) => s * 0.3)
              .toList(); // Lower amplitude to avoid clipping when mixed
      signals.add(samples);
    }

    final mixed = AudioGenerator.mix(signals);
    // Add padding
    final silence = List<double>.filled(4000, 0.0);
    final samples = [...silence, ...mixed, ...silence];

    final bytes = AudioGenerator.encodeWav(samples, sampleRate: 22050);
    final tempFile = File('${Directory.systemTemp.path}/test_c_triad.wav');
    await tempFile.writeAsBytes(bytes);

    // 2. Analyze
    final modelPath =
        '${Directory.current.path}/assets/models/basic_pitch.onnx';
    final detectedNotes = await analyzeAudioFile(
      audioPath: tempFile.path,
      modelPath: modelPath,
    );

    // 3. Verify
    developer.log('Detected notes count: ${detectedNotes.length}');
    for (var n in detectedNotes) {
      developer.log('Note: ${n.midiNote} at ${n.startTime}s');
    }

    final f1 = AccuracyMetrics.calculateF1Score(chordNotes, detectedNotes);
    developer.log('C Major Triad F1 Score: $f1');

    // We expect ALL 3 notes to be detected overlapping in time
    int foundCount = 0;
    for (final expectedMidi in chordNotes) {
      // Look for a note close to the expected pitch, within the expected time window
      final found = detectedNotes.any((n) {
        bool pitchMatch = (n.midiNote - expectedMidi).abs() <= 1;
        // The note starts after padding (4000/22050 ~= 0.18s)
        // Basic Pitch time alignment might be slightly off, so be generous
        bool timeMatch = n.startTime >= 0.1 && n.startTime <= 1.2;
        return pitchMatch && timeMatch;
      });
      if (found) foundCount++;
    }

    // With Monophonic enforcement, we expect ONLY the strongest note(s) to be detected.
    // We shouldn't find all 3 simultaneously anymore.
    // We expect at least one note from the chord to be identified.
    expect(
      foundCount,
      greaterThanOrEqualTo(1),
      reason: 'Expected to find the strongest note of the triad (Monophonic)',
    );

    // Also, verify that we don't have overlapping notes (strict monophony check)
    // Sort by time
    detectedNotes.sort((a, b) => a.startTime.compareTo(b.startTime));
    for (int i = 0; i < detectedNotes.length - 1; i++) {
      final endCurrent = detectedNotes[i].startTime + detectedNotes[i].duration;
      final startNext = detectedNotes[i + 1].startTime;
      // Allow tiny overlap due to float math, but generally should be distinct
      expect(
        startNext,
        greaterThanOrEqualTo(endCurrent - 0.05),
        reason: 'Notes should not overlap significantly in monophonic mode',
      );
    }

    // Clean up
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  group('AccuracyMetrics', () {
    test('calculateF1Score returns 1.0 for perfect match', () {
      final expected = [60, 64, 67];
      final actual = [
        const NoteEvent(
          startTime: 0.1,
          duration: 1.0,
          midiNote: 60,
          confidence: 1.0,
        ),
        const NoteEvent(
          startTime: 0.1,
          duration: 1.0,
          midiNote: 64,
          confidence: 1.0,
        ),
        const NoteEvent(
          startTime: 0.1,
          duration: 1.0,
          midiNote: 67,
          confidence: 1.0,
        ),
      ];

      final score = AccuracyMetrics.calculateF1Score(expected, actual);
      expect(score, equals(1.0));
    });

    test('calculateF1Score handles partial matches', () {
      final expected = [60, 64, 67];
      final actual = [
        const NoteEvent(
          startTime: 0.1,
          duration: 1.0,
          midiNote: 60,
          confidence: 1.0,
        ), // Match
        const NoteEvent(
          startTime: 0.1,
          duration: 1.0,
          midiNote: 72,
          confidence: 1.0,
        ), // False Positive
      ];

      // TP=1, FP=1, FN=2
      // Precision = 1 / (1+1) = 0.5
      // Recall = 1 / (1+2) = 0.333
      // F1 = 2 * (0.5 * 0.333) / (0.5 + 0.333) = 0.4
      final score = AccuracyMetrics.calculateF1Score(expected, actual);
      expect(score, closeTo(0.4, 0.01));
    });
  });
}

class AccuracyMetrics {
  /// Calculates the F1-score for MIDI note detection.
  /// [expectedMidiNotes] is the list of ground truth MIDI notes.
  /// [actualNotes] is the list of NoteEvents returned by the analyzer.
  static double calculateF1Score(
    List<int> expectedMidiNotes,
    List<NoteEvent> actualNotes,
  ) {
    if (expectedMidiNotes.isEmpty && actualNotes.isEmpty) return 1.0;
    if (expectedMidiNotes.isEmpty || actualNotes.isEmpty) return 0.0;

    int truePositives = 0;
    final List<int> remainingExpected = List.from(expectedMidiNotes);
    final List<NoteEvent> falsePositives = [];

    for (final actual in actualNotes) {
      bool matched = false;
      for (int i = 0; i < remainingExpected.length; i++) {
        if ((actual.midiNote - remainingExpected[i]).abs() <= 1) {
          truePositives++;
          remainingExpected.removeAt(i);
          matched = true;
          break;
        }
      }
      if (!matched) {
        falsePositives.add(actual);
      }
    }

    int falseNegatives = remainingExpected.length;
    int totalFalsePositives = falsePositives.length;

    double precision = truePositives / (truePositives + totalFalsePositives);
    double recall = truePositives / (truePositives + falseNegatives);

    if (precision + recall == 0) return 0.0;
    return 2 * (precision * recall) / (precision + recall);
  }
}
