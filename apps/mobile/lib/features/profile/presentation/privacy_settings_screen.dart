import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/profile_provider.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _showName = true;
  bool _showDob = true;
  bool _showPhoto = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    if (!_initialized && profile != null) {
      _showName = profile.showName;
      _showDob = profile.showDob;
      _showPhoto = profile.showPhoto;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Visibility Controls'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DPDPA 2023 Compliant',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Control exactly what information is visible to emergency first responders when they scan your physical QR code or medical tag.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.75),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Public QR Scan Field Visibility',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.person_rounded,
                          color: AppColors.primary),
                      title: const Text('Show Full Legal Name',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Allows responders to address you by name and verify identity at the hospital.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _showName,
                      onChanged: (val) {
                        setState(() => _showName = val);
                        ref.read(profileNotifierProvider.notifier).updatePrivacy(
                              showName: val,
                            );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.cake_rounded,
                          color: AppColors.secondary),
                      title: const Text('Show Age',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Helps paramedics know patient age for pediatric or geriatric drug dosages.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _showDob,
                      onChanged: (val) {
                        setState(() => _showDob = val);
                        ref.read(profileNotifierProvider.notifier).updatePrivacy(
                              showDob: val,
                            );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.photo_camera_rounded,
                          color: AppColors.info),
                      title: const Text('Show Profile Photo',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Provides visual photo verification for unresponsive trauma patients.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _showPhoto,
                      onChanged: (val) {
                        setState(() => _showPhoto = val);
                        ref.read(profileNotifierProvider.notifier).updatePrivacy(
                              showPhoto: val,
                            );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Always Visible During Emergency Scans:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildNonConfigurableItem(
                        icon: Icons.bloodtype_rounded,
                        color: AppColors.primary,
                        title: 'Blood Group & Rh Type',
                        reason: 'Mandatory for zero-delay trauma transfusions',
                      ),
                      const SizedBox(height: 12),
                      _buildNonConfigurableItem(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        title: 'Severe Drug & Food Allergies',
                        reason: 'Prevents fatal anaphylaxis from standard drugs',
                      ),
                      const SizedBox(height: 12),
                      _buildNonConfigurableItem(
                        icon: Icons.contact_emergency_rounded,
                        color: AppColors.success,
                        title: 'Emergency Contacts',
                        reason: 'Essential to notify loved ones and next of kin',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Changes are saved instantly to your secure cloud profile.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNonConfigurableItem({
    required IconData icon,
    required Color color,
    required String title,
    required String reason,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(reason,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65))),
            ],
          ),
        ),
        const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
      ],
    );
  }
}
