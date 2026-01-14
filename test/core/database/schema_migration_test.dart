// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_pitch/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Schema Migration Tests', () {
    test('should store and retrieve accompanimentPath', () async {
      final now = DateTime.now();
      final session = SessionsCompanion.insert(
        filePath: '/path/to/audio.mp3',
        fileName: 'audio.mp3',
        fileSize: 1024,
        durationSeconds: 120.5,
        createdAt: now,
        accompanimentPath: const  Value('/path/to/accompaniment.mp3'),
      );

      final id = await database.into(database.sessions).insert(session);
      expect(id, isPositive);

      final retrievedSession = await (database.select(database.sessions)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(retrievedSession.accompanimentPath, equals('/path/to/accompaniment.mp3'));
    });
  });
}
