// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Pure Pitch Detector`
  String get appTitle {
    return Intl.message(
      'Pure Pitch Detector',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Analyze Audio File`
  String get analyzeAudioFile {
    return Intl.message(
      'Analyze Audio File',
      name: 'analyzeAudioFile',
      desc: '',
      args: [],
    );
  }

  /// `View Logs`
  String get viewLogs {
    return Intl.message('View Logs', name: 'viewLogs', desc: '', args: []);
  }

  /// `Analyzing audio...`
  String get analyzingAudio {
    return Intl.message(
      'Analyzing audio...',
      name: 'analyzingAudio',
      desc: '',
      args: [],
    );
  }

  /// `Ready to Record`
  String get readyToRecord {
    return Intl.message(
      'Ready to Record',
      name: 'readyToRecord',
      desc: '',
      args: [],
    );
  }

  /// `{value} Hz`
  String hz(String value) {
    return Intl.message('$value Hz', name: 'hz', desc: '', args: [value]);
  }

  /// `MIDI: {value}`
  String midi(int value) {
    return Intl.message('MIDI: $value', name: 'midi', desc: '', args: [value]);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
