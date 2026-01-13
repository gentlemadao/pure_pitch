// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clock/clock.dart';

import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/core/utils/asset_loader.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'package:pure_pitch/features/pitch/domain/services/pitch_detector_service.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';

part 'pitch_provider.g.dart';

@riverpod
class Pitch extends _$Pitch {
  AudioRecorder? _recorder;
  StreamSubscription? _sub;
  static const int _sampleRate = 44100;

  @override
  PitchState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _recorder?.dispose();
    });
    return const PitchState();
  }

  Future<void> analyzeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      await analyzePath(result.files.single.path!);
    }
  }

  Future<void> analyzePath(String audioPath) async {
    state = state.copyWith(
      isAnalyzing: true,
      errorMessage: null,
      analysisResults: [],
    );

    try {
      final modelPath = await AssetLoader.loadModelPath('basic_pitch.onnx');
      final noteEvents = await analyzeAudioFile(
        audioPath: audioPath,
        modelPath: modelPath,
      );

      talker.info('Analysis completed. Found ${noteEvents.length} notes.');
      if (noteEvents.isNotEmpty) {
        final last = noteEvents.last;
        final duration = last.startTime + last.duration;
        talker.info('Analysis duration: ${duration.toStringAsFixed(2)}s');
      }

      state = state.copyWith(isAnalyzing: false, analysisResults: noteEvents);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, errorMessage: e.toString());
      talker.error("File analysis failed", e);
    }
  }

  Future<void> toggleCapture() async {
    if (state.isRecording) {
      await _stopCapture();
    } else {
      await _startCapture();
    }
  }

  Future<void> _startCapture() async {
    _recorder ??= AudioRecorder();

    // Request microphone permission using the recorder's own method
    // which works more reliably across all platforms (macOS/iOS/Android/Windows/Linux).
    final hasPermission = await _recorder!.hasPermission();

    if (hasPermission) {
      try {
        final stream = await _recorder!.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: _sampleRate,
            numChannels: 1,
          ),
        );

        _sub = stream.listen(processAudioChunk);

        state = state.copyWith(
          isRecording: true,
          history: [],
          errorMessage: null,
        );
      } catch (e) {
        talker.error("Start capture failed", e);
        state = state.copyWith(errorMessage: "Failed to start capture: $e");
      }
    } else {
      talker.warning("Microphone permission denied");
      state = state.copyWith(
        errorMessage: "Microphone permission is required to record.",
      );
    }
  }

  Future<void> _stopCapture() async {
    try {
      await _recorder?.stop();
      await _sub?.cancel();
      _sub = null;
    } catch (e) {
      talker.error("Stop capture failed", e);
    }
    state = state.copyWith(isRecording: false, currentPitch: null);
  }

  void updateVisibleTimeWindow(double newValue) {
    state = state.copyWith(visibleTimeWindow: newValue.clamp(5.0, 10.0));
  }

  @visibleForTesting
  Future<void> processAudioChunk(Uint8List bytes) async {
    if (bytes.isEmpty) return;

    final length = bytes.length;
    final numSamples = length ~/ 2;
    final samples = Float32List(numSamples);

    final byteData = ByteData.sublistView(bytes);

    for (int i = 0; i < numSamples; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      samples[i] = sample / 32768.0;
    }

    await analyze(samples);
  }

  @visibleForTesting
  Future<void> analyze(Float32List buffer) async {
    if (!ref.mounted) return;
    try {
      final result = await ref.read(pitchDetectorServiceProvider).detectLive(
            samples: buffer,
            sampleRate: _sampleRate.toDouble(),
          );

      if (!ref.mounted) return;

      final now = clock.now();
      final newPoint = TimestampedPitch(
        now,
        hz: result.hz,
        midiNote: result.midiNote,
        clarity: result.clarity,
      );

      final newHistory = [
        ...state.history,
        newPoint,
      ];

      LivePitch? newCurrentPitch = state.currentPitch;
      if (result.clarity > 0.4) {
        newCurrentPitch = result;
      }

      state = state.copyWith(
        history: newHistory,
        currentPitch: newCurrentPitch,
      );
    } catch (e) {
      talker.error("Analysis failed", e);
    }
  }
}
