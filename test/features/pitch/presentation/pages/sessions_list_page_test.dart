// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pure_pitch/features/pitch/data/repositories/session_repository.dart';
import 'package:pure_pitch/features/pitch/presentation/pages/sessions_list_page.dart';
import 'package:pure_pitch/core/database/app_database.dart' as db;

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
  });

  testWidgets('SessionsListPage should show empty message when no sessions', (tester) async {
    when(() => mockRepository.getAllSessions()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: SessionsListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No saved sessions'), findsOneWidget);
  });

  testWidgets('SessionsListPage should list saved sessions', (tester) async {
    final now = DateTime.now();
    when(() => mockRepository.getAllSessions()).thenAnswer((_) async => [
      db.Session(
        id: 1,
        filePath: '/path/1.mp3',
        fileName: 'Song 1.mp3',
        fileSize: 1000,
        durationSeconds: 120,
        createdAt: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: SessionsListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Song 1.mp3'), findsOneWidget);
  });
}
