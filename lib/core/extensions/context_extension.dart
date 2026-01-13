// Copyright (c) 2026. Licensed under the MIT OR Apache-2.0 License.
// SPDX-License-Identifier: MIT OR Apache-2.0
import 'package:flutter/material.dart';
import 'package:pure_pitch/core/localization/generated/l10n.dart';

extension ContextExtension on BuildContext {
  /// Easy access to localizations
  S get l10n => S.of(this);
}
