// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/foundation.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pitch_detector_service.g.dart';

class PitchDetectorService {
  Future<LivePitch> detectLive({
    required Float32List samples,
    required double sampleRate,
  }) {
    return detectPitchLive(samples: samples, sampleRate: sampleRate);
  }
}

@riverpod
PitchDetectorService pitchDetectorService(Ref ref) {
  return PitchDetectorService();
}
