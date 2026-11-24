import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/location_models.dart';
import '../domain/location_provider.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto-acquire position on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationNotifierProvider.notifier).startSharing();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchMaps(double lat, double lon) async {
    final geoUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon(Emergency Responder)');
    final webUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  void _shareCoordinates(UserLocation? loc) {
    if (loc == null) return;
    final mapUrl =
        'https://maps.google.com/?q=${loc.latitude},${loc.longitude}';
    final message =
        '🚨 EMERGENCY SOS LOCATION ALERT!\nMy current live GPS coordinates are:\nLat: ${loc.latitude.toStringAsFixed(5)}, Lon: ${loc.longitude.toStringAsFixed(5)}\nMap: $mapUrl\nSent via Golden Hour Safety App.';
    Share.share(message, subject: '🚨 Emergency Location Alert');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationNotifierProvider);
    final notifier = ref.read(locationNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Emergency Radar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Nearby Responders',
            onPressed: () => notifier.refreshPeers(),
          ),
          IconButton(
            icon: const Icon(Icons.share_location_rounded),
            tooltip: 'Broadcast GPS Coordinates',
            onPressed: () => _shareCoordinates(state.currentLocation),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.refreshPeers(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Live Sharing Status Header Card
                    _buildStatusBanner(context, state, notifier),

                    const SizedBox(height: 16),

                    // 2. Geofence Safe Zone Alert (if breached)
                    if (state.geofenceEvaluation != null)
                      _buildGeofenceAlertBanner(context, state.geofenceEvaluation!),

                    const SizedBox(height: 16),

                    // 3. Visual Radar / Map Canvas
                    _buildRadarMapCard(context, state),

                    const SizedBox(height: 16),

                    // 4. Safe Zone Perimeter Controls
                    _buildSafeZoneConfigCard(context, state, notifier),

                    const SizedBox(height: 16),

                    // 5. Nearby Emergency Responders List
                    _buildNearbyPeersSection(context, state),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    LocationSharingState state,
    LocationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isSharing = state.isSharing;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSharing
                    ? AppColors.success.withValues(alpha: 0.15)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSharing ? Icons.radar_rounded : Icons.location_off_rounded,
                color: isSharing ? AppColors.success : theme.hintColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSharing ? 'Live Radar Active' : 'Location Sharing Paused',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSharing
                        ? 'Streaming encrypted coordinates to responders'
                        : 'Enable to view nearby peers & monitor safe zone',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isSharing,
              activeThumbColor: AppColors.success,
              onChanged: (val) {
                if (val) {
                  notifier.startSharing();
                } else {
                  notifier.stopSharing();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceAlertBanner(
    BuildContext context,
    dynamic geofenceEval,
  ) {
    final isInZone = geofenceEval.isInSafeZone as bool;
    final message = geofenceEval.statusMessage as String;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isInZone
            ? AppColors.successLight
            : AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInZone ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInZone ? Icons.shield_rounded : Icons.warning_amber_rounded,
            color: isInZone ? AppColors.success : AppColors.error,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isInZone
                    ? const Color(0xFF22543D)
                    : const Color(0xFF742A2A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarMapCard(BuildContext context, LocationSharingState state) {
    final loc = state.currentLocation;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        color: const Color(0xFF0F172A), // High contrast dark radar background
        height: 280,
        width: double.infinity,
        child: Stack(
          children: [
            // Custom Radar Grid & Markers Canvas
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 280),
                  painter: RadarMapPainter(
                    pulseValue: _pulseController.value,
                    safeZoneRadiusMeters: state.safeZone.radiusMeters,
                    currentLocation: loc,
                    peers: state.peers,
                  ),
                );
              },
            ),

            // Coordinates readout overlay in top-left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      loc != null
                          ? '${loc.latitude.toStringAsFixed(4)}°, ${loc.longitude.toStringAsFixed(4)}°'
                          : 'Acquiring GPS fix...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Zoom / Radius badge in top-right
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Safe Zone: ${state.safeZone.radiusMeters.toStringAsFixed(0)}m',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bottom action: Center map
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'center_radar_btn',
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.center_focus_strong_rounded,
                    color: Colors.white),
                onPressed: () {
                  if (loc != null) {
                    _launchMaps(loc.latitude, loc.longitude);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeZoneConfigCard(
    BuildContext context,
    LocationSharingState state,
    LocationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final currentRadius = state.safeZone.radiusMeters;
    final radii = [100.0, 250.0, 500.0, 1000.0, 2000.0];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded,
                    color: AppColors.info, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Emergency Safe-Zone Perimeter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select boundary distance. You will receive real-time breach alerts if you move outside this perimeter.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),

            // Radius Selector Chips
            Wrap(
              spacing: 8,
              children: radii.map((r) {
                final isSelected = (currentRadius - r).abs() < 1.0;
                return ChoiceChip(
                  label: Text('${r.toStringAsFixed(0)} m'),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) notifier.updateSafeZoneRadius(r);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // Anchor center button
            OutlinedButton.icon(
              onPressed: state.currentLocation == null
                  ? null
                  : () {
                      final loc = state.currentLocation!;
                      notifier.setSafeZoneCenter(loc.latitude, loc.longitude);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Safe-zone center anchored to your current location!'),
                        ),
                      );
                    },
              icon: const Icon(Icons.pin_drop_rounded, size: 18),
              label: const Text('Anchor Safe-Zone Center to Current Position'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPeersSection(
    BuildContext context,
    LocationSharingState state,
  ) {
    final theme = Theme.of(context);
    final peers = state.peers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Emergency Responders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: peers.isNotEmpty
                    ? AppColors.success.withValues(alpha: 0.15)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${peers.length} active',
                style: TextStyle(
                  color: peers.isNotEmpty ? AppColors.success : theme.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (peers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.people_outline_rounded,
                    size: 36, color: theme.hintColor),
                const SizedBox(height: 8),
                Text(
                  'No active responders within 10 km',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Responders within range will automatically appear here on your live radar.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else
          ...peers.map((peer) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryLight,
                  child: Icon(Icons.person_pin_circle_rounded,
                      color: AppColors.secondary),
                ),
                title: Text(
                  peer.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  peer.distanceMeters != null
                      ? '${peer.distanceMeters!.toStringAsFixed(0)} meters away • Live'
                      : 'Active',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.navigation_rounded,
                      color: AppColors.primary),
                  tooltip: 'Navigate to Responder',
                  onPressed: () => _launchMaps(peer.latitude, peer.longitude),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class RadarMapPainter extends CustomPainter {
  final double pulseValue;
  final double safeZoneRadiusMeters;
  final UserLocation? currentLocation;
  final List<PeerMarker> peers;

  RadarMapPainter({
    required this.pulseValue,
    required this.safeZoneRadiusMeters,
    required this.currentLocation,
    required this.peers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.44;

    // 1. Concentric radar grid rings
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * (i / 4), gridPaint);
    }

    // 2. Crosshair grid lines
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      gridPaint,
    );

    // 3. Geofence Safe-Zone boundary circle
    final geofencePaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final geofenceFill = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Normalize safe-zone radius to canvas
    final safeZoneCanvasRadius = maxRadius * 0.65;
    canvas.drawCircle(center, safeZoneCanvasRadius, geofenceFill);
    canvas.drawCircle(center, safeZoneCanvasRadius, geofencePaint);

    // 4. Peer markers
    final peerPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    if (currentLocation != null) {
      for (int i = 0; i < peers.length; i++) {
        final peer = peers[i];
        final dist = peer.distanceMeters ?? 300.0;
        final dLat = peer.latitude - currentLocation!.latitude;
        final dLon = peer.longitude - currentLocation!.longitude;
        final angle = math.atan2(dLat, dLon);

        // Map distance to radar radius
        final distRatio = math.min(dist / 2000.0, 1.0);
        final peerRadius = maxRadius * distRatio;
        final peerOffset = Offset(
          center.dx + peerRadius * math.cos(angle),
          center.dy - peerRadius * math.sin(angle),
        );

        canvas.drawCircle(peerOffset, 6.0, peerPaint);
      }
    }

    // 5. User center pulsing marker
    final pulsePaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.4 * (1.0 - pulseValue))
      ..style = PaintingStyle.fill;

    final userPinPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    final userPinBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, 12.0 + (pulseValue * 18.0), pulsePaint);
    canvas.drawCircle(center, 8.0, userPinPaint);
    canvas.drawCircle(center, 8.0, userPinBorder);
  }

  @override
  bool shouldRepaint(covariant RadarMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.safeZoneRadiusMeters != safeZoneRadiusMeters ||
        oldDelegate.currentLocation != currentLocation ||
        oldDelegate.peers.length != peers.length;
  }
}
