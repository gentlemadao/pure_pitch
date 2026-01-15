// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pure_pitch/features/pitch/data/repositories/session_repository.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart' as rust;
import 'package:riverpod/riverpod.dart';
import 'package:pure_pitch/core/database/app_database.dart' as db;
import 'dart:io';

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
  });

  test('analyzePath should load from cache if available', () async {
    final container = ProviderContainer(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    const fileName = 'song.mp3';
    
    // Create a real temp file so provider can read length
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes([0, 1, 2, 3]);
    final fileSize = await file.length();
    final filePath = file.path;

    // Use any() matcher to be robust against slight mismatches, 
    // but we know exact values so we can use them too.
    when(() => mockRepository.findSessionByFile(
          fileName: fileName,
          fileSize: fileSize,
        )).thenAnswer((_) async {
          return SessionWithEvents(
            session: db.Session(
              id: 1,
              filePath: filePath,
              fileName: fileName,
              fileSize: fileSize,
              durationSeconds: 10.0,
              createdAt: DateTime.now(),
            ),
            events: [
              const rust.NoteEvent(startTime: 0.0, duration: 1.0, midiNote: 60, confidence: 1.0),
            ],
          );
        });

    // Keep provider alive
    final subscription = container.listen(pitchProvider, (_, _) {});

    final notifier = container.read(pitchProvider.notifier);
    
    // Await the future before the test ends and container is disposed
    await notifier.analyzePath(filePath);

    final state = container.read(pitchProvider);
    expect(state.analysisResults.length, equals(1));
    expect(state.analysisResults.first.midiNote, equals(60));
    
    verify(() => mockRepository.findSessionByFile(
          fileName: fileName,
          fileSize: fileSize,
        )).called(1);
    
    subscription.close();
    await tempDir.delete(recursive: true);
    container.dispose();
  });
}
