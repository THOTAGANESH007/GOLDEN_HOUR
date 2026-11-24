import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../services/secure_storage_service.dart';
import 'app_colors.dart';

class AccentColorOption {
  final String id;
  final String name;
  final Color color;

  const AccentColorOption({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccentColorOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          color.toARGB32() == other.color.toARGB32();

  @override
  int get hashCode => id.hashCode ^ color.toARGB32().hashCode;
}

class ThemeCustomizer {
  static const List<AccentColorOption> accentOptions = [
    AccentColorOption(
      id: 'crimson',
      name: 'Crimson Alert',
      color: AppColors.primary,
    ),
    AccentColorOption(
      id: 'amber',
      name: 'Amber Rescue',
      color: Color(0xFFDD6B20),
    ),
    AccentColorOption(
      id: 'cobalt',
      name: 'Ocean Safety',
      color: Color(0xFF3182CE),
    ),
    AccentColorOption(
      id: 'emerald',
      name: 'Life Emerald',
      color: Color(0xFF38A169),
    ),
    AccentColorOption(
      id: 'amethyst',
      name: 'Royal Amethyst',
      color: Color(0xFF805AD5),
    ),
    AccentColorOption(
      id: 'rose',
      name: 'Vivid Rose',
      color: Color(0xFFE53888),
    ),
    AccentColorOption(
      id: 'teal',
      name: 'Cyan Pulse',
      color: Color(0xFF00A389),
    ),
    AccentColorOption(
      id: 'indigo',
      name: 'Midnight Indigo',
      color: Color(0xFF4C51BF),
    ),
  ];

  static AccentColorOption get defaultAccent => accentOptions.first;

  static AccentColorOption fromId(String id) {
    return accentOptions.firstWhere(
      (opt) => opt.id.toLowerCase() == id.toLowerCase(),
      orElse: () => defaultAccent,
    );
  }

  static AccentColorOption fromColor(Color color) {
    return accentOptions.firstWhere(
      (opt) => opt.color.toARGB32() == color.toARGB32(),
      orElse: () => defaultAccent,
    );
  }
}

final accentOptionsProvider = Provider<List<AccentColorOption>>((ref) {
  return ThemeCustomizer.accentOptions;
});

final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  return AccentColorNotifier(storage, analytics: analytics);
});

class AccentColorNotifier extends StateNotifier<Color> {
  final SecureStorageService _storage;
  final AnalyticsService? _analytics;

  AccentColorNotifier(this._storage, {AnalyticsService? analytics})
      : _analytics = analytics,
        super(ThemeCustomizer.defaultAccent.color) {
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    try {
      final savedId = await _storage.getAccentColor();
      if (savedId != null && savedId.isNotEmpty) {
        state = ThemeCustomizer.fromId(savedId).color;
      }
    } catch (_) {
      // Keep default
    }
  }

  Future<void> setAccentColor(AccentColorOption option) async {
    state = option.color;
    await _storage.saveAccentColor(option.id);
    _analytics?.logThemeChanged(themeMode: 'current', accentColor: option.id);
  }

  Future<void> setAccentColorById(String id) async {
    final opt = ThemeCustomizer.fromId(id);
    await setAccentColor(opt);
  }
}

