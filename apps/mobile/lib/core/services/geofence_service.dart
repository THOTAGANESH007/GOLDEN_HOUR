import 'dart:math' as math;

class GeofenceEvaluation {
  final bool isInSafeZone;
  final double distanceFromCenterMeters;
  final double radiusMeters;
  final bool alertTriggered;
  final String statusMessage;

  const GeofenceEvaluation({
    required this.isInSafeZone,
    required this.distanceFromCenterMeters,
    required this.radiusMeters,
    required this.alertTriggered,
    required this.statusMessage,
  });
}

class GeofenceService {
  /// Evaluates whether current coordinates are within the safe-zone boundary.
  GeofenceEvaluation evaluateZone({
    required double currentLat,
    required double currentLon,
    required double? centerLat,
    required double? centerLon,
    required double radiusMeters,
  }) {
    if (centerLat == null || centerLon == null) {
      return GeofenceEvaluation(
        isInSafeZone: true,
        distanceFromCenterMeters: 0.0,
        radiusMeters: radiusMeters,
        alertTriggered: false,
        statusMessage: 'No safe zone center established. Boundary inactive.',
      );
    }

    final distance = calculateDistanceMeters(
      currentLat,
      currentLon,
      centerLat,
      centerLon,
    );

    final inZone = distance <= radiusMeters;
    final alert = !inZone;

    final msg = inZone
        ? 'Within safe zone (${distance.toStringAsFixed(0)}m / ${radiusMeters.toStringAsFixed(0)}m)'
        : 'Safe zone perimeter breached! ${distance.toStringAsFixed(0)}m from center (limit ${radiusMeters.toStringAsFixed(0)}m)';

    return GeofenceEvaluation(
      isInSafeZone: inZone,
      distanceFromCenterMeters: distance,
      radiusMeters: radiusMeters,
      alertTriggered: alert,
      statusMessage: msg,
    );
  }

  /// Haversine distance helper in meters.
  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * math.pi / 180.0;
    final phi2 = lat2 * math.pi / 180.0;
    final dPhi = (lat2 - lat1) * math.pi / 180.0;
    final dLambda = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dPhi / 2.0) * math.sin(dPhi / 2.0) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2.0) *
            math.sin(dLambda / 2.0);
    final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return r * c;
  }
}

