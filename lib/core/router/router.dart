import 'package:go_router/go_router.dart';
import 'package:pure_pitch/features/pitch/presentation/pages/pitch_detector_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PitchDetectorPage(),
      ),
    ],
  );
}
