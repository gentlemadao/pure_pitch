// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pure_pitch/core/database/app_database.dart';
import 'package:pure_pitch/src/rust/api/pitch.dart' as rust;

part 'session_repository.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
}

class SessionWithEvents {
  final Session session;
  final List<rust.NoteEvent> events;

  SessionWithEvents({required this.session, required this.events});
}

class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  Future<SessionWithEvents?> findSessionByFile({
    required String fileName,
    required int fileSize,
  }) async {
    final session = await (_db.select(_db.sessions)
          ..where((t) => t.fileName.equals(fileName) & t.fileSize.equals(fileSize)))
        .getSingleOrNull();

    if (session == null) return null;

    final dbEvents = await (_db.select(_db.noteEvents)
          ..where((t) => t.sessionId.equals(session.id)))
        .get();

    final events = dbEvents.map((e) => rust.NoteEvent(
      startTime: e.startTime,
      duration: e.duration,
      midiNote: e.midiNote,
      confidence: e.confidence,
    )).toList();

    return SessionWithEvents(
      session: session,
      events: events,
    );
  }

  Future<List<Session>> getAllSessions() async {
    return await (_db.select(_db.sessions)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> deleteSession(int sessionId) async {
    await (_db.delete(_db.sessions)..where((t) => t.id.equals(sessionId))).go();
  }

  Future<void> saveSession({
    required String filePath,
    required String fileName,
    required int fileSize,
    required double durationSeconds,
    required List<rust.NoteEvent> noteEvents,
  }) async {
    await _db.transaction(() async {
      // Check if exists and delete (overwrite strategy)
      final existing = await (_db.select(_db.sessions)
            ..where((t) => t.fileName.equals(fileName) & t.fileSize.equals(fileSize)))
          .getSingleOrNull();
          
      if (existing != null) {
        await (_db.delete(_db.sessions)..where((t) => t.id.equals(existing.id))).go();
      }

      final sessionId = await _db.into(_db.sessions).insert(SessionsCompanion.insert(
            filePath: filePath,
            fileName: fileName,
            fileSize: fileSize,
            durationSeconds: durationSeconds,
            createdAt: DateTime.now(),
          ));

      for (final event in noteEvents) {
        await _db.into(_db.noteEvents).insert(NoteEventsCompanion.insert(
              sessionId: sessionId,
              startTime: event.startTime,
              duration: event.duration,
              midiNote: event.midiNote,
              confidence: event.confidence,
            ));
      }
    });
  }
}