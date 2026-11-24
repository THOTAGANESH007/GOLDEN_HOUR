import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'heading': heading,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
      };
}

class LocationService {
  // Test hook to provide mock positions during widget/unit tests
  static LocationResult? mockPosition;
  static bool mockServiceEnabled = true;
  static LocationPermission mockPermission = LocationPermission.always;

  /// Check whether GPS hardware service is enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    if (mockPosition != null) return mockServiceEnabled;
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Request runtime location permissions from the user.
  Future<LocationPermission> checkAndRequestPermission() async {
    if (mockPosition != null) return mockPermission;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Retrieve the current single GPS fix.
  Future<LocationResult?> getCurrentLocation() async {
    if (mockPosition != null) return mockPosition;

    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        heading: pos.heading,
        speed: pos.speed,
        timestamp: pos.timestamp,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Subscribe to real-time location stream with distance filter.
  Stream<LocationResult> getPositionStream({
    int distanceFilterMeters = 5,
    int intervalSeconds = 5,
  }) {
    if (mockPosition != null) {
      return Stream.value(mockPosition!);
    }

    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilterMeters,
        ),
      ).map(
        (pos) => LocationResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          heading: pos.heading,
          speed: pos.speed,
          timestamp: pos.timestamp,
        ),
      );
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Compute great-circle distance between two GPS coordinates in meters.
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (_) {
      // Fallback Haversine formula
      const r = 6371000.0;
      final phi1 = startLatitude * math.pi / 180.0;
      final phi2 = endLatitude * math.pi / 180.0;
      final dPhi = (endLatitude - startLatitude) * math.pi / 180.0;
      final dLambda = (endLongitude - startLongitude) * math.pi / 180.0;

      final a = math.sin(dPhi / 2.0) * math.sin(dPhi / 2.0) +
          math.cos(phi1) *
              math.cos(phi2) *
              math.sin(dLambda / 2.0) *
              math.sin(dLambda / 2.0);
      final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
      return r * c;
    }
  }
}
