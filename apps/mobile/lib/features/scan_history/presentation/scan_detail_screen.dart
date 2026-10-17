import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/scan_models.dart';
import '../domain/scan_history_provider.dart';

class ScanDetailScreen extends ConsumerStatefulWidget {
  final ScanHistoryItem? initialEvent;
  final String scanId;

  const ScanDetailScreen({
    super.key,
    this.initialEvent,
    required this.scanId,
  });

  @override
  ConsumerState<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends ConsumerState<ScanDetailScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialEvent != null) {
        ref
            .read(scanHistoryNotifierProvider.notifier)
            .selectEvent(widget.initialEvent!);
      }
      ref
          .read(scanHistoryNotifierProvider.notifier)
          .loadDetail(widget.scanId);
      _initCooldownTimer();
    });
  }

  void _initCooldownTimer() {
    final event = widget.initialEvent ??
        ref.read(scanHistoryNotifierProvider).selectedEvent;
    if (event == null || event.isFalseAlarm) return;

    final remaining = event.secondsUntilFalseAlarmAvailable;
    if (remaining > 0) {
      setState(() => _secondsRemaining = remaining);
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final current = _secondsRemaining - 1;
        if (current <= 0) {
          timer.cancel();
          setState(() => _secondsRemaining = 0);
        } else {
          setState(() => _secondsRemaining = current);
        }
      });
    } else {
      setState(() => _secondsRemaining = 0);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _openGoogleMaps(String mapsUrl) async {
    if (mapsUrl.isEmpty) return;
    final uri = Uri.parse(mapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps application')),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label copied to clipboard')),
      );
    }
  }

  Future<void> _confirmMarkFalseAlarm(ScanHistoryItem event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as False Alarm?'),
        content: const Text(
          'This will flag the scan event as accidental or non-emergency. '
          'Your emergency contacts and audit log will record that no medical trauma response was required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Mark False Alarm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(scanHistoryNotifierProvider.notifier)
          .markFalseAlarm(event.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scan event successfully marked as false alarm.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = ref.read(scanHistoryNotifierProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to update scan event.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanHistoryNotifierProvider);
    final event = state.selectedEvent ?? widget.initialEvent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(scanHistoryNotifierProvider.notifier)
                .loadDetail(widget.scanId),
          ),
        ],
      ),
      body: SafeArea(
        child: event == null
            ? (state.isLoadingDetail
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage ?? 'Scan event not found',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(scanHistoryNotifierProvider.notifier)
                              .loadDetail(widget.scanId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ))
            : SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner Card
                    _buildStatusBanner(event),
                    const SizedBox(height: 16),

                    // Responder Information Card
                    _buildResponderCard(event),
                    const SizedBox(height: 16),

                    // Location & GPS Coordinates Card
                    _buildLocationCard(event),
                    const SizedBox(height: 16),

                    // Multi-Channel Dispatch Audit
                    _buildDispatchStatusCard(event),
                    const SizedBox(height: 24),

                    // False Alarm Cooldown Button
                    _buildFalseAlarmSection(event, state.isMarkingFalseAlarm),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBanner(ScanHistoryItem event) {
    final isFalse = event.isFalseAlarm;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFalse
            ? AppColors.warningLight.withValues(alpha: 0.3)
            : AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFalse
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFalse ? AppColors.warning : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFalse
                  ? Icons.notification_important_rounded
                  : Icons.crisis_alert_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isFalse
                          ? 'False Alarm Reported'
                          : 'Emergency QR Scan Event',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isFalse
                            ? Colors.orange.shade900
                            : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Scanned ${event.relativeTime} (${event.formattedDate})',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'QR UID: ${event.qrUid}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponderCard(ScanHistoryItem event) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Responder Identification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Responder Name',
              value: event.responderName ?? 'Not disclosed / Anonymous',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.local_hospital_outlined,
              label: 'Hospital / Station',
              value: event.responderHospital ?? 'Not recorded',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.devices_rounded,
              label: 'Scanner Device',
              value: event.deviceType ?? 'Standard Web Browser',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ScanHistoryItem event) {
    final mapsUrl = event.resolvedMapsUrl;
    final hasCoordinates = event.latitude != null && event.longitude != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Location & GPS Coordinates',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(
              icon: Icons.map_rounded,
              label: 'Location Area',
              value: event.displayLocation,
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.pin_drop_outlined,
                label: 'Exact Coordinates',
                value:
                    '${event.latitude!.toStringAsFixed(5)}, ${event.longitude!.toStringAsFixed(5)}',
                trailing: IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  tooltip: 'Copy Coordinates',
                  onPressed: () => _copyToClipboard(
                    '${event.latitude},${event.longitude}',
                    'GPS coordinates',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => _openGoogleMaps(mapsUrl),
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('Open in Google Maps'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchStatusCard(ScanHistoryItem event) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cell_tower_rounded,
                    color: AppColors.info, size: 20),
                SizedBox(width: 8),
                Text(
                  'Emergency Alert Broadcasts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildChannelStatus(
              channel: 'Fast2SMS Gateway',
              sent: event.smsSent,
              icon: Icons.sms_outlined,
              description: 'Emergency contacts notified via SMS',
            ),
            const SizedBox(height: 12),
            _buildChannelStatus(
              channel: 'WhatsApp (Green-API)',
              sent: event.whatsappSent,
              icon: Icons.chat_bubble_outline_rounded,
              description: 'Location map & alert sent to WhatsApp',
            ),
            const SizedBox(height: 12),
            _buildChannelStatus(
              channel: 'FCM Push Notification',
              sent: event.fcmSent,
              icon: Icons.notifications_active_outlined,
              description: 'Alert dispatched to patient device',
            ),
            const SizedBox(height: 12),
            _buildChannelStatus(
              channel: 'Email Fallback (Resend)',
              sent: event.emailSent,
              icon: Icons.email_outlined,
              description: 'Escalation triggered if SMS fails 3 retries',
            ),
            if (event.notificationSuppressed) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Repeated scan within 5 minutes: Notifications were suppressed to prevent duplicate alert spam.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChannelStatus({
    required String channel,
    required bool sent,
    required IconData icon,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: sent ? AppColors.successLight : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: sent ? AppColors.success : Colors.grey.shade500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: sent ? AppColors.successLight : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: sent
                  ? AppColors.success.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            sent ? 'DELIVERED' : 'NOT TRIGGERED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: sent ? AppColors.success : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildFalseAlarmSection(ScanHistoryItem event, bool isMarking) {
    if (event.isFalseAlarm) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 20),
            SizedBox(width: 8),
            Text(
              'Marked as False Alarm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    final isCooldownActive = _secondsRemaining > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: (isCooldownActive || isMarking)
              ? null
              : () => _confirmMarkFalseAlarm(event),
          icon: isMarking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.report_gmailerrorred_rounded,
                  color: isCooldownActive ? Colors.grey : AppColors.warning,
                ),
          label: Text(
            isCooldownActive
                ? 'False Alarm (Available in ${_secondsRemaining}s)'
                : 'Mark as False Alarm',
            style: TextStyle(
              color: isCooldownActive ? Colors.grey : AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isCooldownActive
                  ? Colors.grey.shade300
                  : AppColors.warning.withValues(alpha: 0.6),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isCooldownActive
              ? 'Security Cooldown: False alarm button unlocks 60s after scan to protect ongoing trauma triage.'
              : 'Tap to mark this scan as accidental or non-emergency.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
