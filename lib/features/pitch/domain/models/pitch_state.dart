// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';

part 'pitch_state.freezed.dart';

@freezed
abstract class TimestampedPitch with _$TimestampedPitch {
  const factory TimestampedPitch(
    DateTime time, {
    required double hz,
    required int midiNote,
    required double clarity,
  }) = _TimestampedPitch;
}

@freezed
abstract class PitchState with _$PitchState {
  const factory PitchState({
    @Default(false) bool isRecording,
    @Default(false) bool isAnalyzing,
    LivePitch? currentPitch,
    @Default([]) List<TimestampedPitch> history,
    @Default([]) List<NoteEvent> analysisResults,
    String? errorMessage,
    @Default(5.0) double visibleTimeWindow,
    String? currentFilePath,
    @Default(0.0) double monitoringVolume,
    @Default(false) bool isAccompanimentEnabled,
    String? accompanimentPath,
  }) = _PitchState;
}
