import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/services/geofence_service.dart';
import 'package:golden_hour/core/services/location_service.dart';
import 'package:golden_hour/features/location/data/location_models.dart';
import 'package:golden_hour/features/location/domain/location_provider.dart';
import 'package:golden_hour/features/location/presentation/live_map_screen.dart';

void main() {
  setUp(() {
    LocationService.mockPosition = LocationResult(
      latitude: 12.9716,
      longitude: 77.5946,
      accuracy: 5.0,
      heading: 90.0,
      speed: 1.2,
      timestamp: DateTime(2026, 11, 24, 10, 0, 0),
    );
    LocationService.mockServiceEnabled = true;
  });

  tearDown(() {
    LocationService.mockPosition = null;
  });

  group('Location Models & GeofenceService Tests', () {
    test('UserLocation serializes and deserializes properly', () {
      final loc = UserLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        accuracy: 10.0,
        heading: 45.0,
        speed: 2.5,
        timestamp: DateTime(2026, 11, 24, 12, 0, 0),
      );

      final json = loc.toJson();
      expect(json['latitude'], 12.9716);
      expect(json['longitude'], 77.5946);

      final fromJson = UserLocation.fromJson(json);
      expect(fromJson.latitude, 12.9716);
      expect(fromJson.longitude, 77.5946);
      expect(fromJson.accuracy, 10.0);
    });

    test('PeerMarker deserializes correctly from json', () {
      final json = {
        'user_id': 'peer_123',
        'display_name': 'Emergency Responder A',
        'latitude': 12.9750,
        'longitude': 77.5980,
        'distance_meters': 350.5,
        'updated_at': '2026-11-24T12:00:00Z',
        'is_sharing': true,
        'status': 'active',
      };

      final peer = PeerMarker.fromJson(json);
      expect(peer.userId, 'peer_123');
      expect(peer.displayName, 'Emergency Responder A');
      expect(peer.distanceMeters, 350.5);
      expect(peer.isSharing, true);
    });

    test('GeofenceService evaluates inside safe zone correctly', () {
      final service = GeofenceService();
      // Center and point within 500m
      final eval = service.evaluateZone(
        currentLat: 12.9720,
        currentLon: 77.5950,
        centerLat: 12.9716,
        centerLon: 77.5946,
        radiusMeters: 500.0,
      );

      expect(eval.isInSafeZone, isTrue);
      expect(eval.alertTriggered, isFalse);
      expect(eval.distanceFromCenterMeters, lessThan(500.0));
    });

    test('GeofenceService detects boundary breach correctly', () {
      final service = GeofenceService();
      // Point 2km away from center with 500m radius
      final eval = service.evaluateZone(
        currentLat: 12.9900,
        currentLon: 77.5946,
        centerLat: 12.9716,
        centerLon: 77.5946,
        radiusMeters: 500.0,
      );

      expect(eval.isInSafeZone, isFalse);
      expect(eval.alertTriggered, isTrue);
      expect(eval.distanceFromCenterMeters, greaterThan(500.0));
      expect(eval.statusMessage, contains('breached'));
    });

    test('GeofenceService handles uninitialized center gracefully', () {
      final service = GeofenceService();
      final eval = service.evaluateZone(
        currentLat: 12.9716,
        currentLon: 77.5946,
        centerLat: null,
        centerLon: null,
        radiusMeters: 500.0,
      );

      expect(eval.isInSafeZone, isTrue);
      expect(eval.alertTriggered, isFalse);
    });

    test('LocationService distanceBetween computes accurate distance', () {
      final locService = LocationService();
      final dist = locService.distanceBetween(
        12.9716,
        77.5946,
        12.9716,
        77.5946,
      );
      expect(dist, 0.0);
    });
  });

  group('LocationNotifier Unit Tests', () {
    test('Notifier starts sharing, acquires position and sets safe zone',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(locationNotifierProvider.notifier);
      final success = await notifier.startSharing(
        userId: 'unit_test_user',
        displayName: 'Test User',
      );

      expect(success, isTrue);
      final state = container.read(locationNotifierProvider);
      expect(state.isSharing, isTrue);
      expect(state.currentLocation, isNotNull);
      expect(state.currentLocation!.latitude, 12.9716);
      expect(state.safeZone.centerLatitude, 12.9716);
      expect(state.geofenceEvaluation, isNotNull);
      expect(state.geofenceEvaluation!.isInSafeZone, isTrue);
    });

    test('Notifier updates safe zone radius and center', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(locationNotifierProvider.notifier);
      await notifier.startSharing();

      notifier.updateSafeZoneRadius(1000.0);
      expect(
          container.read(locationNotifierProvider).safeZone.radiusMeters, 1000.0);

      notifier.setSafeZoneCenter(13.0000, 77.6000);
      expect(
          container.read(locationNotifierProvider).safeZone.centerLatitude,
          13.0000);
    });

    test('Notifier stops sharing and clears active stream', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(locationNotifierProvider.notifier);
      await notifier.startSharing();
      expect(container.read(locationNotifierProvider).isSharing, isTrue);

      await notifier.stopSharing();
      expect(container.read(locationNotifierProvider).isSharing, isFalse);
    });
  });

  group('LiveMapScreen Widget Tests', () {
    testWidgets('Renders radar title, status card, controls, and canvas',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LiveMapScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check App Bar & titles
      expect(find.text('Live Emergency Radar'), findsOneWidget);
      expect(find.text('Emergency Safe-Zone Perimeter'), findsOneWidget);
      expect(find.text('Nearby Emergency Responders'), findsOneWidget);

      // Check radar canvas and coordinates
      expect(find.textContaining('12.9716'), findsOneWidget);
      expect(find.textContaining('Safe Zone: 500m'), findsOneWidget);

      // Check safe zone radius chips
      expect(find.text('100 m'), findsOneWidget);
      expect(find.text('500 m'), findsOneWidget);
      expect(find.text('1000 m'), findsOneWidget);
    });

    testWidgets('Tapping radius chip updates safe-zone perimeter',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LiveMapScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to chip and tap 1000 m
      await tester.ensureVisible(find.text('1000 m'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('1000 m'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Safe Zone: 1000m'), findsOneWidget);
    });
  });
}
