// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/core/extensions/context_extension.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../data/repositories/session_repository.dart';
import '../providers/pitch_provider.dart';

// part 'sessions_list_page.g.dart';

final savedSessionsProvider = FutureProvider<List<db.Session>>((ref) {
  return ref.watch(sessionRepositoryProvider).getAllSessions();
});

class SessionsListPage extends ConsumerWidget {
  const SessionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(savedSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.savedSessions)),
      body: sessionsAsync.when(
        data: (List<db.Session> sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noSavedSessions,
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Dismissible(
                key: Key(session.id.toString()),
                background: Container(
                  color: Colors.cyan.withValues(alpha: 0.8),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.library_music, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.importAccompaniment,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Import logic
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['mp3', 'wav', 'aac'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final detailed = await ref
                          .read(sessionRepositoryProvider)
                          .findSessionByFile(
                            fileName: session.fileName,
                            fileSize: session.fileSize,
                          );
                      if (detailed != null) {
                        await ref
                            .read(sessionRepositoryProvider)
                            .saveSession(
                              filePath: session.filePath,
                              fileName: session.fileName,
                              fileSize: session.fileSize,
                              durationSeconds: session.durationSeconds,
                              noteEvents: detailed.events,
                              accompanimentPath: result.files.single.path!,
                            );
                        ref.invalidate(savedSessionsProvider);
                      }
                    }
                    return false; // Don't dismiss
                  } else if (direction == DismissDirection.endToStart) {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.l10n.deleteSession),
                        content: Text(context.l10n.deleteSessionConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: Text(context.l10n.delete),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      // Delete logic
                      await ref
                          .read(sessionRepositoryProvider)
                          .deleteSession(session.id);
                      ref.invalidate(savedSessionsProvider);
                      return true;
                    }
                    return false;
                  }
                  return false;
                },
                onDismissed: (direction) {},
                child: ListTile(
                  leading: Icon(
                    Icons.music_note,
                    color: session.accompanimentPath != null
                        ? Colors.cyanAccent
                        : Colors.white24,
                  ),
                  title: Text(
                    session.fileName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${(session.durationSeconds).toStringAsFixed(1)}s • ${session.createdAt.toLocal().toString().split('.')[0]}',
                    style: const TextStyle(color: Colors.white38),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                  ),
                  onTap: () async {
                    // Load session
                    final detailed = await ref
                        .read(sessionRepositoryProvider)
                        .findSessionByFile(
                          fileName: session.fileName,
                          fileSize: session.fileSize,
                        );
                    if (detailed != null) {
                      ref.read(pitchProvider.notifier).loadSession(detailed);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(context.l10n.error(e))),
      ),
    );
  }
}
