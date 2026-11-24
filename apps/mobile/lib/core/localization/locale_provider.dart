import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class AppLocales {
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
  ];

  static const defaultLocale = Locale('en');

  static LanguageOption fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => supportedLanguages.first,
    );
  }
}

final supportedLanguagesProvider = Provider<List<LanguageOption>>((ref) {
  return AppLocales.supportedLanguages;
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return LocaleNotifier(storage);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SecureStorageService _storage;

  LocaleNotifier(this._storage) : super(AppLocales.defaultLocale) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final savedCode = await _storage.getLocale();
      if (savedCode != null && savedCode.isNotEmpty) {
        state = Locale(savedCode);
      }
    } catch (_) {
      // Keep default
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _storage.saveLocale(languageCode);
  }
}

