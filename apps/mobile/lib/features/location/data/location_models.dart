import '../../../core/services/geofence_service.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'heading': heading,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

class PeerMarker {
  final String userId;
  final String displayName;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final String updatedAt;
  final bool isSharing;
  final String status;

  const PeerMarker({
    required this.userId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    required this.updatedAt,
    this.isSharing = true,
    this.status = 'active',
  });

  factory PeerMarker.fromJson(Map<String, dynamic> json) => PeerMarker(
        userId: json['user_id'] as String? ?? 'unknown',
        displayName: json['display_name'] as String? ?? 'Emergency Peer',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
        updatedAt: json['updated_at'] as String? ?? '',
        isSharing: json['is_sharing'] as bool? ?? true,
        status: json['status'] as String? ?? 'active',
      );
}

class GeofenceZone {
  final String name;
  final double? centerLatitude;
  final double? centerLongitude;
  final double radiusMeters;
  final bool isEnabled;

  const GeofenceZone({
    this.name = 'Primary Safe Zone',
    this.centerLatitude,
    this.centerLongitude,
    this.radiusMeters = 500.0,
    this.isEnabled = true,
  });

  GeofenceZone copyWith({
    String? name,
    double? centerLatitude,
    double? centerLongitude,
    double? radiusMeters,
    bool? isEnabled,
  }) =>
      GeofenceZone(
        name: name ?? this.name,
        centerLatitude: centerLatitude ?? this.centerLatitude,
        centerLongitude: centerLongitude ?? this.centerLongitude,
        radiusMeters: radiusMeters ?? this.radiusMeters,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

class LocationSharingState {
  final bool isSharing;
  final bool isLoading;
  final UserLocation? currentLocation;
  final GeofenceZone safeZone;
  final GeofenceEvaluation? geofenceEvaluation;
  final List<PeerMarker> peers;
  final double searchRadiusKm;
  final String connectionState; // 'idle' | 'connecting' | 'connected' | 'error'
  final String? errorMessage;

  const LocationSharingState({
    this.isSharing = false,
    this.isLoading = false,
    this.currentLocation,
    this.safeZone = const GeofenceZone(),
    this.geofenceEvaluation,
    this.peers = const [],
    this.searchRadiusKm = 10.0,
    this.connectionState = 'idle',
    this.errorMessage,
  });

  LocationSharingState copyWith({
    bool? isSharing,
    bool? isLoading,
    UserLocation? currentLocation,
    GeofenceZone? safeZone,
    GeofenceEvaluation? geofenceEvaluation,
    List<PeerMarker>? peers,
    double? searchRadiusKm,
    String? connectionState,
    String? errorMessage,
  }) =>
      LocationSharingState(
        isSharing: isSharing ?? this.isSharing,
        isLoading: isLoading ?? this.isLoading,
        currentLocation: currentLocation ?? this.currentLocation,
        safeZone: safeZone ?? this.safeZone,
        geofenceEvaluation: geofenceEvaluation ?? this.geofenceEvaluation,
        peers: peers ?? this.peers,
        searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
        connectionState: connectionState ?? this.connectionState,
        errorMessage: errorMessage,
      );
}
