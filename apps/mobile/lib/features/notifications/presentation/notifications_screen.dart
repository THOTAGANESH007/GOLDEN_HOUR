import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/notification_models.dart';
import '../domain/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifState = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(notificationNotifierProvider.notifier)
                .loadHistory(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(notificationNotifierProvider.notifier)
              .loadHistory(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Push Notification Channel Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instant Emergency Alerting',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'FCM Push and WhatsApp channels are active for all emergency tag scans.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Compose & Test FCM Push Alert Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showComposePushModal(context, ref),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Compose & Send FCM Push Alert'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Scan & Alert Activity Log
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Scan Log (${notifState.events.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (notifState.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (notifState.events.isEmpty && !notifState.isLoading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 44,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No Emergency Scans Recorded',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When first responders or bystanders scan your QR code, real-time alerts and scene details will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifState.events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final event = notifState.events[index];
                      return _buildScanEventCard(context, ref, event);
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanEventCard(
    BuildContext context,
    WidgetRef ref,
    ScanEventItem event,
  ) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('MMM d, yyyy • h:mm a').format(event.scannedAt.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.isFalseAlarm
                        ? theme.colorScheme.surfaceContainerHighest
                        : AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event.isFalseAlarm
                        ? Icons.report_off_rounded
                        : Icons.emergency_rounded,
                    color: event.isFalseAlarm
                        ? theme.colorScheme.onSurfaceVariant
                        : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.isFalseAlarm
                            ? 'Scan Event (False Alarm)'
                            : 'Emergency QR Scanned',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: event.isFalseAlarm
                              ? theme.colorScheme.onSurface
                              : AppColors.error,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (event.isFalseAlarm)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('False Alarm',
                        style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),

            if (event.responderName != null ||
                event.responderHospital != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.local_hospital_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${event.responderName ?? "First Responder"} • ${event.responderHospital ?? "En route"}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            if (event.googleMapsUrl != null) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => launchUrl(Uri.parse(event.googleMapsUrl!)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text(
                      event.locationArea ?? 'View GPS Location on Google Maps',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Notification Delivery Badges
            Row(
              children: [
                _buildChannelBadge(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  sent: event.smsSent,
                ),
                const SizedBox(width: 8),
                _buildChannelBadge(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  sent: event.whatsappSent,
                ),
                const SizedBox(width: 8),
                _buildChannelBadge(
                  icon: Icons.notifications_none,
                  label: 'FCM Push',
                  sent: event.fcmSent,
                ),
                const Spacer(),
                if (!event.isFalseAlarm)
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Mark as False Alarm?'),
                          content: const Text(
                            'This informs emergency contacts that this scan was not an actual trauma incident.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        ref
                            .read(notificationNotifierProvider.notifier)
                            .markFalseAlarm(event.id);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'False Alarm?',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelBadge({
    required IconData icon,
    required String label,
    required bool sent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: sent ? AppColors.successLight : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: sent ? AppColors.success.withValues(alpha: 0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: sent ? AppColors.success : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: sent ? AppColors.success : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showComposePushModal(BuildContext context, WidgetRef ref) {
    final titleController =
        TextEditingController(text: '🚨 Emergency Alert — Immediate Action');
    final bodyController = TextEditingController(
        text: 'Safety profile was accessed. Tap to review scene coordinates.');
    String selectedCategory = NotificationCategory.emergencySos;
    bool isDataOnly = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Compose Push Notification',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category selection chips
                    const Text('Notification Category:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('🚨 Emergency SOS'),
                          selected:
                              selectedCategory == NotificationCategory.emergencySos,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedCategory =
                                  NotificationCategory.emergencySos);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('💡 Safety Tip'),
                          selected:
                              selectedCategory == NotificationCategory.safetyTip,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedCategory =
                                  NotificationCategory.safetyTip);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('📡 Radar Alert'),
                          selected:
                              selectedCategory == NotificationCategory.radarAlert,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedCategory =
                                  NotificationCategory.radarAlert);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('📢 App Update'),
                          selected:
                              selectedCategory == NotificationCategory.appUpdate,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedCategory =
                                  NotificationCategory.appUpdate);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Data-only toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data-Only (Silent Background Sync)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Routes data packet directly to background handler without top banner.',
                        style: TextStyle(fontSize: 11),
                      ),
                      value: isDataOnly,
                      onChanged: (val) => setModalState(() => isDataOnly = val),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final messenger = ScaffoldMessenger.of(context);
                          final res = await ref
                              .read(notificationNotifierProvider.notifier)
                              .dispatchPush(
                                title: titleController.text.trim(),
                                body: bodyController.text.trim(),
                                category: selectedCategory,
                                isDataOnly: isDataOnly,
                              );
                          if (res != null) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Push dispatched! (${res.successCount} delivered)',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Dispatch Push Notification'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
