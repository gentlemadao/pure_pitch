// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/core/database/app_database.dart';
import 'package:pure_pitch/features/pitch/data/repositories/session_repository.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart' as rust; // Alias import

void main() {
  late AppDatabase database;
  late SessionRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SessionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SessionRepository', () {
    test('should return null if session does not exist', () async {
      final result = await repository.findSessionByFile(
        fileName: 'unknown.mp3',
        fileSize: 1234,
      );
      expect(result, isNull);
    });

    test('should save and retrieve a session with note events', () async {
      final now = DateTime.now();
      
      // Save
      await repository.saveSession(
        filePath: '/path/song.mp3',
        fileName: 'song.mp3',
        fileSize: 1000,
        durationSeconds: 60.0,
        noteEvents: [
          const rust.NoteEvent(startTime: 1.0, duration: 2.0, midiNote: 60, confidence: 0.9),
          const rust.NoteEvent(startTime: 3.0, duration: 1.0, midiNote: 62, confidence: 0.8),
        ],
      );

      // Retrieve
      final session = await repository.findSessionByFile(
        fileName: 'song.mp3',
        fileSize: 1000,
      );

      expect(session, isNotNull);
      expect(session!.session.fileName, equals('song.mp3'));
      expect(session.events.length, equals(2));
      // Verify mapped event
      expect(session.events[0].midiNote, equals(60));
      expect(session.events[0].startTime, equals(1.0));
    });
  });
}