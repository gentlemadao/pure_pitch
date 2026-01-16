// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Use in-memory database for testing
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Schema Tests', () {
    test('should insert and retrieve a session', () async {
      final now = DateTime.now();
      final session = SessionsCompanion.insert(
        filePath: '/path/to/audio.mp3',
        fileName: 'audio.mp3',
        fileSize: 1024,
        durationSeconds: 120.5,
        createdAt: now,
      );

      final id = await database.into(database.sessions).insert(session);
      expect(id, isPositive);

      final retrievedSession = await (database.select(
        database.sessions,
      )..where((tbl) => tbl.id.equals(id))).getSingle();

      expect(retrievedSession.fileName, equals('audio.mp3'));
      expect(retrievedSession.fileSize, equals(1024));
    });

    test('should insert and retrieve note events for a session', () async {
      final now = DateTime.now();
      final session = SessionsCompanion.insert(
        filePath: '/path/to/song.wav',
        fileName: 'song.wav',
        fileSize: 2048,
        durationSeconds: 60.0,
        createdAt: now,
      );

      final sessionId = await database.into(database.sessions).insert(session);

      final noteEvent = NoteEventsCompanion.insert(
        sessionId: sessionId,
        startTime: 1.5,
        duration: 0.5,
        midiNote: 60,
        confidence: 0.95,
      );

      await database.into(database.noteEvents).insert(noteEvent);

      final notes = await (database.select(
        database.noteEvents,
      )..where((tbl) => tbl.sessionId.equals(sessionId))).get();

      expect(notes.length, equals(1));
      expect(notes.first.midiNote, equals(60));
    });

    test('should cascade delete note events when session is deleted', () async {
      final now = DateTime.now();
      final sessionId = await database
          .into(database.sessions)
          .insert(
            SessionsCompanion.insert(
              filePath: 'del.mp3',
              fileName: 'del.mp3',
              fileSize: 100,
              durationSeconds: 10,
              createdAt: now,
            ),
          );

      await database
          .into(database.noteEvents)
          .insert(
            NoteEventsCompanion.insert(
              sessionId: sessionId,
              startTime: 1,
              duration: 1,
              midiNote: 60,
              confidence: 1.0,
            ),
          );

      await (database.delete(
        database.sessions,
      )..where((t) => t.id.equals(sessionId))).go();

      final notes = await (database.select(
        database.noteEvents,
      )..where((t) => t.sessionId.equals(sessionId))).get();
      expect(notes, isEmpty);
    });
  });
}
