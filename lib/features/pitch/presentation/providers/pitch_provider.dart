// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clock/clock.dart';
import 'package:path/path.dart' as p;

import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/core/utils/asset_loader.dart';
import 'package:pure_pitch/features/pitch/data/repositories/session_repository.dart';
import 'package:pure_pitch/features/pitch/domain/models/pitch_state.dart';
import 'package:pure_pitch/features/pitch/domain/services/pitch_detector_service.dart';
import 'package:pure_pitch/features/pitch/domain/utils/pitch_smoother.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';

part 'pitch_provider.g.dart';

@riverpod
class Pitch extends _$Pitch {
  AudioRecorder? _recorder;
  StreamSubscription? _sub;
  Timer? _refinementTimer;
  static const int _sampleRate = 44100;
  late final PitchSmoother _smoother;

  @override
  PitchState build() {
    _smoother = PitchSmoother();
    ref.onDispose(() {
      _sub?.cancel();
      _refinementTimer?.cancel();
      _recorder?.dispose();
    });
    return const PitchState();
  }

  Future<void> analyzeFile() async {
    clearError();
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
      final file = File(audioPath);
      final fileName = p.basename(audioPath);
      final fileSize = await file.length();

      // 1. Check Cache
      final repo = ref.read(sessionRepositoryProvider);
      final cached = await repo.findSessionByFile(
        fileName: fileName,
        fileSize: fileSize,
      );

      if (cached != null) {
        talker.info('Loading analysis results from cache for $fileName');
        if (ref.mounted) {
          state = state.copyWith(
            isAnalyzing: false,
            analysisResults: cached.events,
          );
        }
        return;
      }

      // 2. Run Inference
      final modelPath = await AssetLoader.loadModelPath('basic_pitch.onnx');
      final noteEvents = await analyzeAudioFile(
        audioPath: audioPath,
        modelPath: modelPath,
      );

      talker.info('Analysis completed. Found ${noteEvents.length} notes.');
      double duration = 0;
      if (noteEvents.isNotEmpty) {
        final last = noteEvents.last;
        duration = last.startTime + last.duration;
        talker.info('Analysis duration: ${duration.toStringAsFixed(2)}s');
      }

      // 3. Save to Cache
      await repo.saveSession(
        filePath: audioPath,
        fileName: fileName,
        fileSize: fileSize,
        durationSeconds: duration,
        noteEvents: noteEvents,
      );

      if (ref.mounted) {
        state = state.copyWith(isAnalyzing: false, analysisResults: noteEvents);
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isAnalyzing: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> toggleCapture() async {
    clearError();
    if (state.isRecording) {
      await _stopCapture();
    } else {
      await _startCapture();
    }
  }

  Future<void> _startCapture() async {
    _recorder ??= AudioRecorder();

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
        _startRefinementTimer();

        state = state.copyWith(
          isRecording: true,
          history: [],
          errorMessage: null,
        );
      } catch (e) {
        state = state.copyWith(errorMessage: "Failed to start capture: $e");
      }
    } else {
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
      _stopRefinementTimer();
      // Final refinement
      _refineHistory();
    } catch (e) {
      // Silently handle stop errors if any
    }
    state = state.copyWith(isRecording: false, currentPitch: null);
  }

  void _startRefinementTimer() {
    _refinementTimer?.cancel();
    _refinementTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refineHistory();
    });
  }

  void _stopRefinementTimer() {
    _refinementTimer?.cancel();
    _refinementTimer = null;
  }

  /// Tier 2 Refinement: Back-fill history with better smoothed data.
  void _refineHistory() {
    if (state.history.isEmpty) return;

    final history = List<TimestampedPitch>.from(state.history);
    if (history.length < 5) return;

    // Focus refinement only on the last ~1 second of data (approx 20-25 points)
    // Data older than this is already considered 'mature' and stable.
    final int startIdx = max(0, history.length - 25);
    final segment = history.sublist(startIdx);

    final hzValues = segment.map((p) => p.hz).toList();
    final refinedHz = PitchSmoother.smoothBatch(hzValues, window: 3);

    bool changed = false;
    for (int i = 0; i < segment.length; i++) {
      if (segment[i].hz != refinedHz[i]) {
        history[startIdx + i] = TimestampedPitch(
          segment[i].time,
          hz: refinedHz[i],
          midiNote: PitchSmoother.hzToMidi(refinedHz[i]),
          clarity: segment[i].clarity,
        );
        changed = true;
      }
    }

    if (changed) {
      state = state.copyWith(history: history);
    }
  }

  void updateVisibleTimeWindow(double newValue) {
    state = state.copyWith(visibleTimeWindow: newValue.clamp(5.0, 10.0));
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void loadSession(SessionWithEvents sessionWithEvents) {
    state = state.copyWith(
      analysisResults: sessionWithEvents.events,
      isRecording: false,
      history: [],
      currentPitch: null,
    );
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

      // Apply Smoothing
      final smoothed = _smoother.smooth(result.hz, result.midiNote);

      final now = clock.now();
      final newPoint = TimestampedPitch(
        now,
        hz: smoothed.hz,
        midiNote: smoothed.midiNote,
        clarity: result.clarity,
      );

      final newHistory = [
        ...state.history,
        newPoint,
      ];

      LivePitch? newCurrentPitch = state.currentPitch;
      if (result.clarity > 0.4) {
        newCurrentPitch = LivePitch(
          hz: smoothed.hz,
          midiNote: smoothed.midiNote,
          clarity: result.clarity,
        );
      }

      state = state.copyWith(
        history: newHistory,
        currentPitch: newCurrentPitch,
      );
    } catch (e) {
      // Avoid excessive error logging in high-frequency loop
    }
  }
}
