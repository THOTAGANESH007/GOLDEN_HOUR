import 'package:flutter/services.dart';
import 'guide_model.dart';

class GuideRepository {
  final AssetBundle _bundle;
  final Map<String, String> _contentCache = {};

  GuideRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const List<EmergencyGuide> _bundledGuides = [
    EmergencyGuide(
      id: 'cpr_guidance',
      title: 'Cardiopulmonary Resuscitation (CPR)',
      category: 'Cardiac & Breathing',
      summary: 'Immediate hands-only chest compression protocol and AED safety steps.',
      iconName: 'favorite_rounded',
      assetPath: 'assets/guides/cpr_guidance.md',
      readTimeMinutes: 3,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'choking_response',
      title: 'Choking Relief & Airway',
      category: 'Cardiac & Breathing',
      summary: '5-and-5 protocol (back blows and abdominal thrusts / Heimlich maneuver).',
      iconName: 'air_rounded',
      assetPath: 'assets/guides/choking_response.md',
      readTimeMinutes: 2,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'severe_bleeding',
      title: 'Severe Bleeding & Hemorrhage',
      category: 'Trauma & Wounds',
      summary: 'Direct pressure, wound packing, and limb tourniquet emergency steps.',
      iconName: 'water_drop_rounded',
      assetPath: 'assets/guides/severe_bleeding.md',
      readTimeMinutes: 3,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'fracture_immobilization',
      title: 'Fracture & Bone Immobilization',
      category: 'Trauma & Wounds',
      summary: 'Splinting, sling support, and stabilizing suspected fractures and sprains.',
      iconName: 'accessibility_new_rounded',
      assetPath: 'assets/guides/fracture_immobilization.md',
      readTimeMinutes: 3,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'burns_response',
      title: 'Burn Response & Heat Safety',
      category: 'Burns & Heat',
      summary: 'Cooling protocol, thermal and chemical burn management, and dressings.',
      iconName: 'local_fire_department_rounded',
      assetPath: 'assets/guides/burns_response.md',
      readTimeMinutes: 3,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'heat_exhaustion',
      title: 'Heat Exhaustion & Heatstroke',
      category: 'Environmental',
      summary: 'Rapid cooling, vascular cold packs, and safe hydration guidance.',
      iconName: 'wb_sunny_rounded',
      assetPath: 'assets/guides/heat_exhaustion.md',
      readTimeMinutes: 3,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'seizure_response',
      title: 'Seizure Bystander Safety',
      category: 'General Safety',
      summary: 'Head protection, recovery position, timing, and critical warnings.',
      iconName: 'shield_rounded',
      assetPath: 'assets/guides/seizure_response.md',
      readTimeMinutes: 2,
      lastUpdated: '2026-11-20',
    ),
    EmergencyGuide(
      id: 'shock_prevention',
      title: 'Emergency Shock Management',
      category: 'General Safety',
      summary: 'Elevation, thermal warmth preservation, and vital monitoring.',
      iconName: 'monitor_heart_rounded',
      assetPath: 'assets/guides/shock_prevention.md',
      readTimeMinutes: 2,
      lastUpdated: '2026-11-20',
    ),
  ];

  List<EmergencyGuide> getAllGuides() {
    return List.unmodifiable(_bundledGuides);
  }

  List<String> getCategories() {
    final categories = <String>{'All'};
    for (final guide in _bundledGuides) {
      categories.add(guide.category);
    }
    return categories.toList();
  }

  Future<String> loadGuideContent(String assetPath) async {
    if (_contentCache.containsKey(assetPath)) {
      return _contentCache[assetPath]!;
    }

    try {
      final content = await _bundle.loadString(assetPath);
      _contentCache[assetPath] = content;
      return content;
    } catch (e) {
      throw Exception('Failed to load guide content from $assetPath: $e');
    }
  }

  Future<EmergencyGuide?> getGuideById(String id) async {
    final matches = _bundledGuides.where((g) => g.id == id);
    if (matches.isEmpty) return null;

    final guide = matches.first;
    final content = await loadGuideContent(guide.assetPath);
    return guide.copyWith(content: content);
  }

  List<EmergencyGuide> searchGuides({
    String query = '',
    String category = 'All',
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _bundledGuides.where((guide) {
      final matchesCategory =
          category == 'All' || guide.category.toLowerCase() == category.toLowerCase();

      if (!matchesCategory) return false;

      if (cleanQuery.isEmpty) return true;

      final titleMatch = guide.title.toLowerCase().contains(cleanQuery);
      final summaryMatch = guide.summary.toLowerCase().contains(cleanQuery);
      final categoryMatch = guide.category.toLowerCase().contains(cleanQuery);

      return titleMatch || summaryMatch || categoryMatch;
    }).toList();
  }
}

