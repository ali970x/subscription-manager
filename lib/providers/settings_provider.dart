import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);

@immutable
class SettingsState {
  const SettingsState({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.system,
    this.baseCurrency = 'USD',
    this.notificationHour = 9,
  });
  final Locale locale;
  final ThemeMode themeMode;
  final String baseCurrency;
  final int notificationHour;

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? baseCurrency,
    int? notificationHour,
  }) => SettingsState(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    notificationHour: notificationHour ?? this.notificationHour,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs)
    : super(
        SettingsState(
          locale: Locale(_prefs.getString('language') ?? 'ar'),
          themeMode: ThemeMode.values.firstWhere(
            (mode) => mode.name == _prefs.getString('theme'),
            orElse: () => ThemeMode.system,
          ),
          baseCurrency: _prefs.getString('currency') ?? 'USD',
          notificationHour: _prefs.getInt('notificationHour') ?? 9,
        ),
      );
  final SharedPreferences _prefs;

  Future<void> setLocale(String language) async {
    state = state.copyWith(locale: Locale(language));
    await _prefs.setString('language', language);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString('theme', mode.name);
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(baseCurrency: currency);
    await _prefs.setString('currency', currency);
  }

  Future<void> setNotificationHour(int hour) async {
    state = state.copyWith(notificationHour: hour);
    await _prefs.setInt('notificationHour', hour);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)),
);
