import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/geofence_service.dart';
import '../../../core/services/location_service.dart';
import '../data/location_models.dart';
import '../data/location_repository.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  return GeofenceService();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final repo = LocationRepository(apiClient: apiClient);
  ref.onDispose(() => repo.disconnectWebSocket());
  return repo;
});

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationSharingState>((ref) {
  final locService = ref.watch(locationServiceProvider);
  final geofenceService = ref.watch(geofenceServiceProvider);
  final repo = ref.watch(locationRepositoryProvider);

  return LocationNotifier(
    locationService: locService,
    geofenceService: geofenceService,
    repository: repo,
  );
});

class LocationNotifier extends StateNotifier<LocationSharingState> {
  final LocationService _locationService;
  final GeofenceService _geofenceService;
  final LocationRepository _repository;

  StreamSubscription<LocationResult>? _positionSub;
  String _activeUserId = 'current_user';
  String _activeDisplayName = 'You';

  LocationNotifier({
    required LocationService locationService,
    required GeofenceService geofenceService,
    required LocationRepository repository,
  })  : _locationService = locationService,
        _geofenceService = geofenceService,
        _repository = repository,
        super(const LocationSharingState());

  @override
  void dispose() {
    _positionSub?.cancel();
    _repository.disconnectWebSocket();
    super.dispose();
  }

  /// Start live location sharing with WebSocket streaming and geofence monitoring
  Future<bool> startSharing({
    String? userId,
    String? displayName,
  }) async {
    if (state.isSharing) return true;

    state = state.copyWith(isLoading: true, errorMessage: null);

    _activeUserId = userId ?? _activeUserId;
    _activeDisplayName = displayName ?? _activeDisplayName;

    // 1. Check permission and GPS
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Location services are disabled on this device. Please enable GPS.',
      );
      return false;
    }

    final initialLocation = await _locationService.getCurrentLocation();
    if (initialLocation == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to acquire initial GPS fix. Check location permissions.',
      );
      return false;
    }

    final userLoc = UserLocation(
      latitude: initialLocation.latitude,
      longitude: initialLocation.longitude,
      accuracy: initialLocation.accuracy,
      heading: initialLocation.heading,
      speed: initialLocation.speed,
      timestamp: initialLocation.timestamp,
    );

    // Establish default safe zone center around initial location if unset
    var currentSafeZone = state.safeZone;
    if (currentSafeZone.centerLatitude == null || currentSafeZone.centerLongitude == null) {
      currentSafeZone = currentSafeZone.copyWith(
        centerLatitude: userLoc.latitude,
        centerLongitude: userLoc.longitude,
      );
    }

    final geofenceEval = _geofenceService.evaluateZone(
      currentLat: userLoc.latitude,
      currentLon: userLoc.longitude,
      centerLat: currentSafeZone.centerLatitude,
      centerLon: currentSafeZone.centerLongitude,
      radiusMeters: currentSafeZone.radiusMeters,
    );

    state = state.copyWith(
      isSharing: true,
      isLoading: false,
      currentLocation: userLoc,
      safeZone: currentSafeZone,
      geofenceEvaluation: geofenceEval,
      connectionState: 'connecting',
    );

    // 2. Connect WebSocket
    _repository.connectWebSocket(
      onMessage: _handleWebSocketMessage,
      onError: (err) {
        state = state.copyWith(
          connectionState: 'error',
          errorMessage: 'WebSocket disconnected, streaming over secure REST channel.',
        );
      },
      onDone: () {
        state = state.copyWith(connectionState: 'idle');
      },
    );

    // 3. Publish initial coordinate
    await _repository.sendLocationUpdate(
      userId: _activeUserId,
      displayName: _activeDisplayName,
      location: userLoc,
      safeZone: currentSafeZone,
    );

    // 4. Start continuous GPS stream
    _positionSub?.cancel();
    _positionSub = _locationService.getPositionStream().listen((pos) {
      _onPositionUpdated(pos);
    });

    // 5. Fetch nearby peers
    refreshPeers();

    return true;
  }

  /// Stop live sharing, cancel stream, and disconnect
  Future<void> stopSharing() async {
    _positionSub?.cancel();
    _positionSub = null;

    await _repository.stopSharing(_activeUserId);
    _repository.disconnectWebSocket();

    state = state.copyWith(
      isSharing: false,
      connectionState: 'idle',
      errorMessage: null,
    );
  }

  /// Internal handler when GPS position changes
  void _onPositionUpdated(LocationResult pos) {
    if (!mounted || !state.isSharing) return;

    final userLoc = UserLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      heading: pos.heading,
      speed: pos.speed,
      timestamp: pos.timestamp,
    );

    final geofenceEval = _geofenceService.evaluateZone(
      currentLat: userLoc.latitude,
      currentLon: userLoc.longitude,
      centerLat: state.safeZone.centerLatitude,
      centerLon: state.safeZone.centerLongitude,
      radiusMeters: state.safeZone.radiusMeters,
    );

    if (!mounted) return;
    state = state.copyWith(
      currentLocation: userLoc,
      geofenceEvaluation: geofenceEval,
    );

    _repository.sendLocationUpdate(
      userId: _activeUserId,
      displayName: _activeDisplayName,
      location: userLoc,
      safeZone: state.safeZone,
    );
  }

  /// Process incoming messages from WebSocket
  void _handleWebSocketMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type'] as String?;
    if (type == 'ack') {
      List<PeerMarker> peers = state.peers;
      if (data['peers'] is List) {
        peers = (data['peers'] as List)
            .map((p) => PeerMarker.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      if (!mounted) return;
      state = state.copyWith(
        connectionState: 'connected',
        peers: peers,
      );
    } else if (type == 'peers' && data['peers'] is List) {
      final peers = (data['peers'] as List)
          .map((p) => PeerMarker.fromJson(p as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      state = state.copyWith(peers: peers);
    }
  }

  /// Update geofence radius (e.g. 250m, 500m, 1000m, 2000m)
  void updateSafeZoneRadius(double radiusMeters) {
    final updatedZone = state.safeZone.copyWith(radiusMeters: radiusMeters);
    GeofenceEvaluation? eval;

    if (state.currentLocation != null) {
      eval = _geofenceService.evaluateZone(
        currentLat: state.currentLocation!.latitude,
        currentLon: state.currentLocation!.longitude,
        centerLat: updatedZone.centerLatitude,
        centerLon: updatedZone.centerLongitude,
        radiusMeters: updatedZone.radiusMeters,
      );
    }

    state = state.copyWith(
      safeZone: updatedZone,
      geofenceEvaluation: eval,
    );

    if (state.isSharing && state.currentLocation != null) {
      _repository.sendLocationUpdate(
        userId: _activeUserId,
        displayName: _activeDisplayName,
        location: state.currentLocation!,
        safeZone: updatedZone,
      );
    }
  }

  /// Set safe zone center to given coordinates (or current GPS location)
  void setSafeZoneCenter(double lat, double lon) {
    final updatedZone = state.safeZone.copyWith(
      centerLatitude: lat,
      centerLongitude: lon,
    );

    GeofenceEvaluation? eval;
    if (state.currentLocation != null) {
      eval = _geofenceService.evaluateZone(
        currentLat: state.currentLocation!.latitude,
        currentLon: state.currentLocation!.longitude,
        centerLat: lat,
        centerLon: lon,
        radiusMeters: updatedZone.radiusMeters,
      );
    }

    state = state.copyWith(
      safeZone: updatedZone,
      geofenceEvaluation: eval,
    );
  }

  /// Query nearby emergency peers
  Future<void> refreshPeers() async {
    final loc = state.currentLocation;
    if (loc == null) return;

    final peers = await _repository.fetchNearbyPeers(
      userId: _activeUserId,
      lat: loc.latitude,
      lon: loc.longitude,
      radiusKm: state.searchRadiusKm,
    );

    if (!mounted) return;
    state = state.copyWith(peers: peers);
  }
}
