import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/network/api_client.dart';
import 'location_models.dart';

class LocationRepository {
  final ApiClient _apiClient;
  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  LocationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Open WebSocket connection to /ws/location
  void connectWebSocket({
    required void Function(Map<String, dynamic> data) onMessage,
    required void Function(dynamic error) onError,
    required void Function() onDone,
  }) {
    disconnectWebSocket();

    try {
      final baseUrl = _apiClient.dio.options.baseUrl;
      final uri = Uri.parse(baseUrl);
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = uri.replace(scheme: wsScheme, path: '/ws/location');

      _channel = WebSocketChannel.connect(wsUri);
      _channelSub = _channel?.stream.listen(
        (message) {
          try {
            if (message is String) {
              final decoded = json.decode(message) as Map<String, dynamic>;
              onMessage(decoded);
            }
          } catch (e) {
            debugPrint('Failed to parse WebSocket message: $e');
          }
        },
        onError: onError,
        onDone: onDone,
      );
    } catch (e) {
      onError(e);
    }
  }

  /// Send real-time update through WebSocket if connected, otherwise via REST
  Future<void> sendLocationUpdate({
    required String userId,
    required String displayName,
    required UserLocation location,
    required GeofenceZone safeZone,
  }) async {
    final payload = {
      'type': 'update',
      'data': {
        'user_id': userId,
        'display_name': displayName,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'heading': location.heading,
        'speed': location.speed,
        'timestamp': location.timestamp.toIso8601String(),
        'is_sharing': true,
        'safe_zone_radius_meters': safeZone.radiusMeters,
        'safe_zone_center_lat': safeZone.centerLatitude,
        'safe_zone_center_lon': safeZone.centerLongitude,
      },
    };

    if (_channel != null) {
      try {
        _channel?.sink.add(json.encode(payload));
        return;
      } catch (e) {
        debugPrint('WebSocket sink send failed, falling back to REST: $e');
      }
    }

    // REST fallback
    try {
      await updateLocationRest(
        userId: userId,
        displayName: displayName,
        location: location,
        safeZone: safeZone,
      );
    } catch (e) {
      debugPrint('REST fallback send failed: $e');
    }
  }

  /// REST fallback endpoint: POST /api/v1/location/update
  Future<Map<String, dynamic>?> updateLocationRest({
    required String userId,
    required String displayName,
    required UserLocation location,
    required GeofenceZone safeZone,
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/api/v1/location/update',
        data: {
          'user_id': userId,
          'display_name': displayName,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'heading': location.heading,
          'speed': location.speed,
          'timestamp': location.timestamp.toIso8601String(),
          'is_sharing': true,
          'safe_zone_radius_meters': safeZone.radiusMeters,
          'safe_zone_center_lat': safeZone.centerLatitude,
          'safe_zone_center_lon': safeZone.centerLongitude,
        },
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating location via REST: $e');
      return null;
    }
  }

  /// Fetch active peers nearby: GET /api/v1/location/peers
  Future<List<PeerMarker>> fetchNearbyPeers({
    required String userId,
    required double lat,
    required double lon,
    double radiusKm = 10.0,
  }) async {
    try {
      final res = await _apiClient.dio.get(
        '/api/v1/location/peers',
        queryParameters: {
          'user_id': userId,
          'lat': lat,
          'lon': lon,
          'radius_km': radiusKm,
        },
      );
      final list = (res.data['peers'] as List<dynamic>? ?? []);
      return list
          .map((item) => PeerMarker.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error fetching nearby peers: ${e.message}');
      return [];
    }
  }

  /// Stop sharing: POST /api/v1/location/stop and notify WS
  Future<void> stopSharing(String userId) async {
    if (_channel != null) {
      try {
        _channel?.sink.add(json.encode({'type': 'stop', 'user_id': userId}));
      } catch (_) {}
    }

    try {
      await _apiClient.dio.post(
        '/api/v1/location/stop',
        data: {'user_id': userId},
      );
    } catch (_) {}
  }

  /// Cleanly close WebSocket and subscriptions
  void disconnectWebSocket() {
    _channelSub?.cancel();
    _channelSub = null;
    _channel?.sink.close();
    _channel = null;
  }
}
