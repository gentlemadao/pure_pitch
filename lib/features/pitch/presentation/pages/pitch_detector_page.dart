// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/core/localization/generated/l10n.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';
import 'package:pure_pitch/features/pitch/presentation/pages/sessions_list_page.dart';
import 'package:pure_pitch/features/settings/presentation/providers/locale_provider.dart';

class PitchDetectorPage extends ConsumerStatefulWidget {
  const PitchDetectorPage({super.key});

  @override
  ConsumerState<PitchDetectorPage> createState() => _PitchDetectorPageState();
}

class _PitchDetectorPageState extends ConsumerState<PitchDetectorPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double? _lastAutoScaledWidth;
  double _baseWindowOnScaleStart = 5.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (ref.read(pitchProvider).isRecording) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleResize(double width) {
    if (_lastAutoScaledWidth == width) return;
    _lastAutoScaledWidth = width;

    double autoWindow;
    if (width < 600) {
      autoWindow = 5.0;
    } else if (width > 1200) {
      autoWindow = 10.0;
    } else {
      autoWindow = 5.0 + (width - 600) / 600 * 5.0;
    }

    // Update state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pitchProvider.notifier).updateVisibleTimeWindow(autoWindow);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pitchState = ref.watch(pitchProvider);

    ref.listen(pitchProvider.select((s) => s.isRecording), (prev, recording) {
      if (recording) {
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });

    final currentPitch = pitchState.currentPitch;
    final isRecording = pitchState.isRecording;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appTitle),
        actions: [
          IconButton(
            onPressed: () => ref.read(pitchProvider.notifier).analyzeFile(),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: S.of(context).analyzeAudioFile,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.cyanAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).appTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).toolsAndHistory,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(S.of(context).savedSessions),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SessionsListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(S.of(context).viewLogs),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TalkerScreen(talker: talker),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language / 语言'),
              trailing: DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appLocaleProvider.notifier).setLocale(Locale(value));
                    Navigator.pop(context);
                  }
                },
                underline: const SizedBox(),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _handleResize(constraints.maxWidth);

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseWindowOnScaleStart = ref
                        .read(pitchProvider)
                        .visibleTimeWindow;
                  },
                  onScaleUpdate: (details) {
                    if (details.scale == 1.0) return;
                    // scale > 1 means zoom in -> smaller window
                    final newWindow = _baseWindowOnScaleStart / details.scale;
                    ref
                        .read(pitchProvider.notifier)
                        .updateVisibleTimeWindow(newWindow);
                  },
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(
                      begin: pitchState.visibleTimeWindow,
                      end: pitchState.visibleTimeWindow,
                    ),
                    builder: (context, value, child) {
                      return PitchVisualizer(
                        history: pitchState.history,
                        noteEvents: pitchState.analysisResults,
                        isRecording: isRecording,
                        visibleTimeWindow: value,
                      );
                    },
                  ),
                ),
              ),

              // Audio Control Bar
              Positioned(
                top: 10,
                left: 60, // Avoid overlapping piano labels
                right: 20,
                child: Row(
                  children: [
                    // Volume Cycle Button
                    _ControlChip(
                      onPressed: () => ref.read(pitchProvider.notifier).cycleMonitoringVolume(),
                      icon: pitchState.monitoringVolume == 0
                          ? Icons.volume_off
                          : (pitchState.monitoringVolume < 0.5 ? Icons.volume_down : Icons.volume_up),
                      label: '${(pitchState.monitoringVolume * 100).toInt()}%',
                      isActive: pitchState.monitoringVolume > 0,
                    ),
                    const SizedBox(width: 10),
                    // Accompaniment Toggle
                    if (pitchState.accompanimentPath != null)
                      _ControlChip(
                        onPressed: () => ref.read(pitchProvider.notifier).toggleAccompaniment(!pitchState.isAccompanimentEnabled),
                        icon: Icons.library_music,
                        label: S.of(context).accompanimentLabel,
                        isActive: pitchState.isAccompanimentEnabled,
                      ),
                  ],
                ),
              ),

              if (pitchState.isAnalyzing)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.cyanAccent),
                      const SizedBox(height: 10),
                      Text(
                        S.of(context).analyzingAudio,
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                    ],
                  ),
                ),

              if (pitchState.errorMessage != null)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => ref.read(pitchProvider.notifier).clearError(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10)
                        ],
                      ),
                      child: Text(
                        pitchState.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    if (currentPitch != null && isRecording) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              S.of(context).hz(currentPitch.hz.toStringAsFixed(1)),
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyanAccent,
                                  ),
                            ),
                            Text(
                              S.of(context).midi(currentPitch.midiNote),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!isRecording) ...[
                      const SizedBox(height: 100),
                      Text(
                        S.of(context).readyToRecord,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: isRecording
                      ? FloatingActionButton.large(
                          onPressed: () =>
                              ref.read(pitchProvider.notifier).toggleCapture(),
                          backgroundColor: Colors.redAccent,
                          child: const Icon(Icons.stop),
                        )
                      : FloatingActionButton.large(
                          onPressed: () =>
                              ref.read(pitchProvider.notifier).toggleCapture(),
                          backgroundColor: Colors.cyanAccent,
                          child: const Icon(Icons.mic, color: Colors.black),
                        ),
                ),
              ),

              // Zoom Controls
              Positioned(
                right: 20,
                bottom: 120,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      onPressed: () {
                        ref
                            .read(pitchProvider.notifier)
                            .updateVisibleTimeWindow(
                              pitchState.visibleTimeWindow - 1.0,
                            );
                      },
                      heroTag: 'zoom_in',
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      onPressed: () {
                        ref
                            .read(pitchProvider.notifier)
                            .updateVisibleTimeWindow(
                              pitchState.visibleTimeWindow + 1.0,
                            );
                      },
                      heroTag: 'zoom_out',
                      child: const Icon(Icons.zoom_out),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isActive;

  const _ControlChip({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.cyanAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.cyanAccent : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.cyanAccent : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}