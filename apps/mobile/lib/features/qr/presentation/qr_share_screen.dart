import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/domain/profile_provider.dart';
import '../domain/qr_provider.dart';

class QRShareScreen extends ConsumerStatefulWidget {
  const QRShareScreen({super.key});

  @override
  ConsumerState<QRShareScreen> createState() => _QRShareScreenState();
}

class _QRShareScreenState extends ConsumerState<QRShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  Future<Uint8List?> _captureCardPng() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing QR card: $e');
      return null;
    }
  }

  Future<void> _downloadQr() async {
    setState(() => _isExporting = true);
    try {
      final pngBytes = await _captureCardPng();
      if (pngBytes == null) {
        throw Exception('Could not capture QR card image');
      }

      final qrUid = ref.read(qrNotifierProvider).qrUid ?? 'emergency';
      final fileName = 'golden_hour_qr_$qrUid';

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await ImageGallerySaverPlus.saveImage(
          pngBytes,
          name: fileName,
          quality: 100,
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName.png');
        await file.writeAsBytes(pngBytes);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR Code saved to photo gallery!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareQrImage() async {
    setState(() => _isExporting = true);
    try {
      final pngBytes = await _captureCardPng();
      if (pngBytes == null) {
        throw Exception('Could not capture QR card image');
      }

      final tempDir = await getTemporaryDirectory();
      final qrUid = ref.read(qrNotifierProvider).qrUid ?? 'emergency';
      final file = File('${tempDir.path}/golden_hour_$qrUid.png');
      await file.writeAsBytes(pngBytes);

      final qrUrl = ref.read(qrNotifierProvider).qrUrl ?? '';
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Here is my Golden Hour Emergency Medical QR Code. In an emergency, first responders can scan this to view my critical medical profile: $qrUrl',
        subject: 'My Golden Hour Emergency QR Code',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareQrLink() async {
    final qrUrl = ref.read(qrNotifierProvider).qrUrl;
    if (qrUrl != null && qrUrl.isNotEmpty) {
      await Share.share(
        'Here is my Golden Hour Emergency Medical Link: $qrUrl',
        subject: 'Emergency Medical Profile',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrState = ref.watch(qrNotifierProvider);
    final profile = ref.watch(profileNotifierProvider).profile;
    final bloodGroup = profile?.bloodGroup ?? 'Unknown';
    final fullName = profile?.fullName ?? 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Emergency QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // Printable Card Wrapped in RepaintBoundary
              Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    width: 310,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.health_and_safety_rounded,
                                color: AppColors.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'GOLDEN HOUR',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'EMERGENCY MEDICAL ID',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (qrState.qrUrl != null &&
                            qrState.qrUrl!.isNotEmpty)
                          QrImageView(
                            data: qrState.qrUrl!,
                            version: QrVersions.auto,
                            size: 190.0,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF1A202C),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF1A202C),
                            ),
                          )
                        else
                          const SizedBox(
                            height: 190,
                            child: Center(child: Text('No QR Data')),
                          ),

                        const SizedBox(height: 14),

                        // Blood Group Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'BLOOD GROUP',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                bloodGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Scan with any smartphone camera',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Export Options Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: _isExporting ? null : _downloadQr,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: const Text('Save QR Card to Gallery (PNG)'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isExporting ? null : _shareQrImage,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share QR Image to Family / Doctor'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _shareQrLink,
                        icon: const Icon(Icons.link_rounded),
                        label: const Text('Copy & Share Public Link'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
