import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pure_pitch/app.dart';
import 'package:pure_pitch/src/rust/frb_generated.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();

  runApp(const ProviderScope(child: App()));
}
