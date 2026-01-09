import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/features/pitch/presentation/providers/pitch_provider.dart';
import 'package:pure_pitch/features/pitch/presentation/widgets/pitch_visualizer.dart';

class PitchDetectorPage extends ConsumerStatefulWidget {
  const PitchDetectorPage({super.key});

  @override
  ConsumerState<PitchDetectorPage> createState() => _PitchDetectorPageState();
}

class _PitchDetectorPageState extends ConsumerState<PitchDetectorPage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;

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
          title: const Text('Pure Pitch Detector'),
          actions: [
            IconButton(
              onPressed: () => ref.read(pitchProvider.notifier).analyzeFile(),
              icon: const Icon(Icons.audio_file),
              tooltip: "Analyze Audio File",
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: PitchVisualizer(
                history: pitchState.history,
                timeWindowSeconds: 5.0,
              ),
            ),
            
            if (pitchState.isAnalyzing)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.cyanAccent),
                    SizedBox(height: 10),
                    Text("Analyzing audio...", style: TextStyle(color: Colors.cyanAccent)),
                  ],
                ),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   const SizedBox(height: 30),
                   if (currentPitch != null && isRecording) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                  "${currentPitch.hz.toStringAsFixed(1)} Hz",
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyanAccent,
                                  ),
                              ),
                              Text(
                                  "MIDI: ${currentPitch.midiNote}",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                   ] else if (!isRecording) ...[
                        const SizedBox(height: 100),
                        const Text("Ready to Record", style: TextStyle(fontSize: 24, color: Colors.white54)),
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
                        onPressed: () => ref.read(pitchProvider.notifier).toggleCapture(),
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.stop),
                      )
                    : FloatingActionButton.large(
                        onPressed: () => ref.read(pitchProvider.notifier).toggleCapture(),
                        backgroundColor: Colors.cyanAccent,
                        child: const Icon(Icons.mic, color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
    );
  }
}
