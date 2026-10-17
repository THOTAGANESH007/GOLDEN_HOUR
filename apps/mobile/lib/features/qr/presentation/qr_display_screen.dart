import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/domain/profile_provider.dart';
import '../domain/qr_provider.dart';

class QRDisplayScreen extends ConsumerWidget {
  const QRDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final qrState = ref.watch(qrNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final bloodGroup = profile?.bloodGroup ?? 'Unknown';
    final fullName = profile?.fullName ?? 'Patient';
    final isQrActive = profile?.qrIsActive ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview Responder Page',
            onPressed: qrState.qrUid != null
                ? () => context.push('/qr/preview?uid=${qrState.qrUid}')
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share QR',
            onPressed: qrState.qrUrl != null
                ? () => context.push('/qr/share')
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: qrState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    // Offline / Active Banner
                    if (qrState.isOffline)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.offline_bolt_rounded,
                                color: AppColors.secondary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Viewing offline cached QR code. Available without internet.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!isQrActive)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'QR tag is currently DEACTIVATED. Scanning will return a deactivated notice to responders.',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Main QR Code Container Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 28),
                        child: Column(
                          children: [
                            // Header badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.health_and_safety_rounded,
                                      color: AppColors.primary, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'GOLDEN HOUR EMERGENCY ID',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // QR Image rendered via qr_flutter
                            if (qrState.qrUrl != null &&
                                qrState.qrUrl!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrState.qrUrl!,
                                  version: QrVersions.auto,
                                  size: 230.0,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF1A202C),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(
                                height: 230,
                                child: Center(
                                  child: Text('QR Code not generated yet'),
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Prominent Blood Group Below QR
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'BLOOD GROUP',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bloodGroup,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Patient Name & UID
                            Text(
                              fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'UID: ${qrState.qrUid ?? 'N/A'}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons grid
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/qr/share'),
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Share / Save'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: qrState.qrUid != null
                                ? () => context
                                    .push('/qr/preview?uid=${qrState.qrUid}')
                                : null,
                            icon: const Icon(Icons.preview_rounded),
                            label: const Text('Preview Page'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Regenerate QR Button
                    TextButton.icon(
                      onPressed: qrState.isRegenerating
                          ? null
                          : () => _confirmRegenerate(context, ref),
                      icon: qrState.isRegenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded,
                              color: AppColors.error),
                      label: Text(
                        qrState.isRegenerating
                            ? 'Regenerating...'
                            : 'Regenerate QR Code',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _confirmRegenerate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerate QR Code?'),
        content: const Text(
          'This will permanently deactivate your existing QR code. Any physical stickers, cards, or keychains with the previous QR code will immediately stop working.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(qrNotifierProvider.notifier).regenerateQr();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New QR code generated! Old QR is invalidated.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final err = ref.read(qrNotifierProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err ?? 'Failed to regenerate QR code.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
