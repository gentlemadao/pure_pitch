import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:pure_pitch/core/extensions/context_extension.dart';
import 'package:pure_pitch/core/logger/talker.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';

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
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => ref.read(pitchProvider.notifier).analyzeFile(),
            icon: const Icon(Icons.audio_file),
            tooltip: context.l10n.analyzeAudioFile,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TalkerScreen(talker: talker),
              ),
            ),
            icon: const Icon(Icons.bug_report),
            tooltip: context.l10n.viewLogs,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _handleResize(constraints.maxWidth);

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseWindowOnScaleStart =
                        ref.read(pitchProvider).visibleTimeWindow;
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
// ... rest of the build method stays similar, but I need to make sure I don't break the Stack structure.
// I will apply the change more precisely below.

          if (pitchState.isAnalyzing)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.cyanAccent),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.analyzingAudio,
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pitchState.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
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
                          context.l10n.hz(currentPitch.hz.toStringAsFixed(1)),
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                        ),
                        Text(
                          context.l10n.midi(currentPitch.midiNote),
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ] else if (!isRecording) ...[
                  const SizedBox(height: 100),
                  Text(
                    context.l10n.readyToRecord,
                    style: const TextStyle(fontSize: 24, color: Colors.white54),
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
                                  .updateVisibleTimeWindow(pitchState.visibleTimeWindow - 1.0);
                            },
                            heroTag: 'zoom_in',
                            child: const Icon(Icons.zoom_in),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton.small(
                            onPressed: () {
                              ref
                                  .read(pitchProvider.notifier)
                                  .updateVisibleTimeWindow(pitchState.visibleTimeWindow + 1.0);
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
          );  }
}
