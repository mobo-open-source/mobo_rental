import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Centralized haptic feedback helpers.
/// Keeps usage consistent across the app and makes it easy to adjust per-platform.
class HapticsService {
  HapticsService._();

  /// Triggers a subtle feedback vibration for UI selections.
  static Future<void> selection() async {
    // Subtle feedback for UI selections
    await HapticFeedback.selectionClick();
  }

  /// Triggers a light impact haptic feedback.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggers a medium impact haptic feedback.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggers a heavy impact haptic feedback.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Triggers a pleasant success-pattern haptic vibration.
  static Future<void> success() async {
    // Try to emulate success feedback. iOS has distinct patterns, Android limited.
    // Do a medium impact followed by a light click for a pleasant success feel.
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.selectionClick();
  }

  /// Triggers a light vibration for warnings.
  static Future<void> warning() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggers a heavy vibration for errors.
  static Future<void> error() async {
    // Slightly stronger feedback for errors
    await HapticFeedback.heavyImpact();
  }

  /// Convenience wrapper to respect platforms where haptics are undesirable.
  /// Currently returns true for mobile platforms. Extend this if needed.
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;
}
