import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Settings model
// ---------------------------------------------------------------------------

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.autoOpen = false,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  final ThemeMode themeMode;
  final bool autoOpen;
  final bool soundEnabled;
  final bool hapticEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? autoOpen,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      autoOpen: autoOpen ?? this.autoOpen,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<AppSettings> {
  static const _keyTheme = 'theme_mode';
  static const _keyAutoOpen = 'auto_open';
  static const _keySound = 'sound_enabled';
  static const _keyHaptic = 'haptic_enabled';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      themeMode: ThemeMode.values[prefs.getInt(_keyTheme) ?? ThemeMode.dark.index],
      autoOpen: prefs.getBool(_keyAutoOpen) ?? false,
      soundEnabled: prefs.getBool(_keySound) ?? true,
      hapticEnabled: prefs.getBool(_keyHaptic) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setAutoOpen(bool value) async {
    state = state.copyWith(autoOpen: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoOpen, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }

  Future<void> setHapticEnabled(bool value) async {
    state = state.copyWith(hapticEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
