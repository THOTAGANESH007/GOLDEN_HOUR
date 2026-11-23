import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/features/offline_guides/data/guide_model.dart';
import 'package:golden_hour/features/offline_guides/data/guide_repository.dart';
import 'package:golden_hour/features/offline_guides/domain/guide_provider.dart';
import 'package:golden_hour/features/offline_guides/presentation/guide_detail_screen.dart';
import 'package:golden_hour/features/offline_guides/presentation/guides_screen.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> _assets;

  _FakeAssetBundle(this._assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw FlutterError('Unable to load asset: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    final list = Uint8List.fromList(str.codeUnits);
    return ByteData.view(list.buffer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBundle = _FakeAssetBundle({
    'assets/guides/cpr_guidance.md':
        '# Cardiopulmonary Resuscitation (Hands-Only CPR)\n\n> EMERGENCY NOTICE: Call 112 immediately.\n\n### Step 1: Check responsiveness\nPush hard and fast.',
    'assets/guides/severe_bleeding.md':
        '# Severe Bleeding Response\n\nApply direct pressure firmly.',
    'assets/guides/burns_response.md':
        '# Burn Response\n\nCool under running water for 10-20 minutes.',
  });

  group('Offline Guides — Data & Repository Unit Tests', () {
    test('GuideModel supports copyWith, toMap, fromMap, and equality', () {
      const guide = EmergencyGuide(
        id: 'test_guide',
        title: 'Test Guide',
        category: 'Trauma & Wounds',
        summary: 'A short test guide summary.',
        iconName: 'healing',
        assetPath: 'assets/guides/test.md',
        readTimeMinutes: 2,
        lastUpdated: '2026-11-20',
      );

      final map = guide.toMap();
      expect(map['id'], 'test_guide');
      expect(map['title'], 'Test Guide');
      expect(map['readTimeMinutes'], 2);

      final restored = EmergencyGuide.fromMap(map);
      expect(restored, equals(guide));

      final updated = guide.copyWith(title: 'Updated Title', content: '# Content');
      expect(updated.title, 'Updated Title');
      expect(updated.content, '# Content');
      expect(updated.id, guide.id);
    });

    test('GuideRepository returns all bundled guides', () {
      final repo = GuideRepository(bundle: mockBundle);
      final guides = repo.getAllGuides();

      expect(guides.length, equals(8));
      expect(guides.any((g) => g.id == 'cpr_guidance'), isTrue);
      expect(guides.any((g) => g.id == 'severe_bleeding'), isTrue);
      expect(guides.any((g) => g.id == 'burns_response'), isTrue);
    });

    test('GuideRepository extracts unique categories with All', () {
      final repo = GuideRepository(bundle: mockBundle);
      final categories = repo.getCategories();

      expect(categories.first, equals('All'));
      expect(categories.contains('Cardiac & Breathing'), isTrue);
      expect(categories.contains('Trauma & Wounds'), isTrue);
      expect(categories.contains('Burns & Heat'), isTrue);
      expect(categories.contains('Environmental'), isTrue);
      expect(categories.contains('General Safety'), isTrue);
    });

    test('GuideRepository loads markdown content from bundle and caches', () async {
      final repo = GuideRepository(bundle: mockBundle);
      final content = await repo.loadGuideContent('assets/guides/cpr_guidance.md');

      expect(content, contains('Cardiopulmonary Resuscitation'));
      expect(content, contains('Push hard and fast'));

      // Subsequent read should hit in-memory cache
      final cachedContent =
          await repo.loadGuideContent('assets/guides/cpr_guidance.md');
      expect(cachedContent, equals(content));
    });

    test('GuideRepository getGuideById populates content', () async {
      final repo = GuideRepository(bundle: mockBundle);
      final guide = await repo.getGuideById('cpr_guidance');

      expect(guide, isNotNull);
      expect(guide!.id, 'cpr_guidance');
      expect(guide.content, contains('Cardiopulmonary Resuscitation'));
    });

    test('GuideRepository search filters by query and category', () {
      final repo = GuideRepository(bundle: mockBundle);

      // Search by query across all
      final cprResults = repo.searchGuides(query: 'cpr');
      expect(cprResults.length, equals(1));
      expect(cprResults.first.id, equals('cpr_guidance'));

      // Search by category
      final traumaGuides = repo.searchGuides(category: 'Trauma & Wounds');
      expect(traumaGuides.length, equals(2));
      expect(traumaGuides.any((g) => g.id == 'severe_bleeding'), isTrue);
      expect(traumaGuides.any((g) => g.id == 'fracture_immobilization'), isTrue);

      // Search with non-matching query
      final emptyResults = repo.searchGuides(query: 'xyznonexistent123');
      expect(emptyResults, isEmpty);
    });
  });

  group('Offline Guides — Riverpod Notifier Unit Tests', () {
    test('GuideNotifier initializes with all guides and categories', () {
      final repo = GuideRepository(bundle: mockBundle);
      final notifier = GuideNotifier(repo);

      expect(notifier.state.allGuides.length, equals(8));
      expect(notifier.state.filteredGuides.length, equals(8));
      expect(notifier.state.selectedCategory, equals('All'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('GuideNotifier updates state on category selection and search query', () {
      final repo = GuideRepository(bundle: mockBundle);
      final notifier = GuideNotifier(repo);

      notifier.selectCategory('Trauma & Wounds');
      expect(notifier.state.selectedCategory, equals('Trauma & Wounds'));
      expect(notifier.state.filteredGuides.length, equals(2));

      notifier.search('bleeding');
      expect(notifier.state.searchQuery, equals('bleeding'));
      expect(notifier.state.filteredGuides.length, equals(1));
      expect(notifier.state.filteredGuides.first.id, equals('severe_bleeding'));

      notifier.clearSearch();
      expect(notifier.state.searchQuery, isEmpty);
      expect(notifier.state.filteredGuides.length, equals(2));
    });

    test('GuideNotifier loads and caches guide details', () async {
      final repo = GuideRepository(bundle: mockBundle);
      final notifier = GuideNotifier(repo);

      final guide = await notifier.loadGuideDetail('cpr_guidance');
      expect(guide, isNotNull);
      expect(guide!.content, contains('Cardiopulmonary Resuscitation'));
      expect(notifier.state.loadedGuideDetails.containsKey('cpr_guidance'), isTrue);
    });
  });

  group('Offline Guides — Widget Tests', () {
    testWidgets('GuidesScreen renders title, offline badge, search, and guide cards',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = GuideRepository(bundle: mockBundle);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guideRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & offline badge
      expect(find.text('Emergency Safety Guides'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);

      // Verify search bar & category chips
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Cardiac & Breathing'), findsWidgets);
      expect(find.text('Trauma & Wounds'), findsWidgets);

      // Verify guide cards exist
      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsOneWidget);
      expect(find.text('Severe Bleeding & Hemorrhage'), findsOneWidget);
      expect(find.text('Burn Response & Heat Safety'), findsOneWidget);
    });

    testWidgets('GuidesScreen filtering and searching works in UI',
        (tester) async {
      final repo = GuideRepository(bundle: mockBundle);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guideRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text "burn"
      await tester.enterText(find.byType(TextField), 'burn');
      await tester.pumpAndSettle();

      expect(find.text('Burn Response & Heat Safety'), findsOneWidget);
      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsOneWidget);
    });

    testWidgets('GuidesScreen displays empty state when no guides match',
        (tester) async {
      final repo = GuideRepository(bundle: mockBundle);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guideRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzznonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No guides found'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      await tester.tap(find.text('Reset Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsOneWidget);
    });

    testWidgets('GuideDetailScreen renders content, banner, and bottom action bar',
        (tester) async {
      final repo = GuideRepository(bundle: mockBundle);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guideRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: GuideDetailScreen(guideId: 'cpr_guidance'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and emergency banner
      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsWidgets);
      expect(find.textContaining('EMERGENCY NOTICE:'), findsWidgets);

      // Check Markdown rendering
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Push hard and fast'), findsOneWidget);

      // Check bottom action buttons
      expect(find.text('Back to Guides'), findsOneWidget);
      expect(find.text('Call 112'), findsOneWidget);
    });
  });
}
