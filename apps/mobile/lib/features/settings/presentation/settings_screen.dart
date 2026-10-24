import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/domain/auth_provider.dart';
import '../../profile/domain/profile_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeletingAccount = false;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of Golden Hour? You will need to verify your phone number with OTP to log back in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Account?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Under the Digital Personal Data Protection Act (DPDPA 2023) Right to Erasure, deleting your account will permanently wipe:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text('• Your entire medical profile and emergency contacts'),
            Text('• All encrypted medical records & uploaded documents'),
            Text('• Your emergency QR code (scanners will show invalid)'),
            Text('• All emergency scan history and responder logs'),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeletingAccount = true);
      final success =
          await ref.read(authNotifierProvider.notifier).deleteAccount();

      if (mounted) {
        setState(() => _isDeletingAccount = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account and all personal data have been completely deleted.'),
              backgroundColor: AppColors.textPrimary,
            ),
          );
          context.go('/login');
        } else {
          final error = ref.read(authNotifierProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to delete account. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showInfoModal({
    required String title,
    required String body,
    IconData icon = Icons.info_outline_rounded,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 24,
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final theme = Theme.of(context);
    final phone = authState.phone ?? profile?.bloodGroup ?? 'Registered Patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
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
              // User Account Card
              _buildAccountCard(phone, profile?.fullName),
              const SizedBox(height: 20),

              // Legal & Compliance
              _buildSectionHeader('LEGAL & COMPLIANCE (INDIA DPDPA)'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: AppColors.success, size: 20),
                      ),
                      title: const Text(
                        'DPDPA 2023 Privacy Policy',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Purpose limitation, data minimization, consent records',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onTap: () => _showInfoModal(
                        title: 'DPDPA 2023 Privacy Policy',
                        icon: Icons.shield_rounded,
                        body:
                            'Golden Hour complies with the Digital Personal Data Protection Act, 2023 (DPDPA):\n\n'
                            '1. Purpose Limitation: Personal and medical data is collected strictly for emergency triage and trauma response identification.\n\n'
                            '2. Lawful Consent: All data processing is rooted in explicit, unbundled affirmative consent captured during onboarding.\n\n'
                            '3. Right to Erasure: Patients have an absolute right to wipe their entire data record at any time via the Delete Account button.\n\n'
                            '4. Data Localization & Security: Sensitive health records are stored encrypted at rest with strict Row Level Security (RLS).',
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.medical_services_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      title: const Text(
                        'Medical Responder Disclaimer',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Good Samaritan protection and emergency triage rules',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onTap: () => _showInfoModal(
                        title: 'Medical Responder Disclaimer',
                        icon: Icons.medical_services_rounded,
                        body:
                            'IMPORTANT MEDICAL TRIAGE ADVISORY:\n\n'
                            '• Golden Hour is an emergency identification and first-aid advisory platform, not a substitute for clinical diagnostics.\n\n'
                            '• Paramedics and responders must exercise independent clinical discretion.\n\n'
                            '• Responders and Good Samaritans assisting the patient are protected under the Supreme Court of India Good Samaritan Guidelines and Motor Vehicles (Amendment) Act 2019 Section 134A.',
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined,
                            color: AppColors.info, size: 20),
                      ),
                      title: const Text(
                        'Terms of Service',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Golden Hour platform terms and limitations',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onTap: () => _showInfoModal(
                        title: 'Terms of Service',
                        icon: Icons.description_rounded,
                        body:
                            'Golden Hour Terms of Service:\n\n'
                            '1. Accuracy of Information: The patient is responsible for keeping their blood group, allergies, medications, and emergency contacts accurate and updated.\n\n'
                            '2. Availability: While Golden Hour strives for 99.9% uptime, network dispatches depend on cellular carrier gateways (SMS/WhatsApp) and device internet connectivity.\n\n'
                            '3. Emergency Services: Always dial 112 or 108 in India immediately in life-threatening trauma situations.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 4: Account Danger Zone
              _buildSectionHeader('ACCOUNT ACTIONS'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 22,
                      ),
                      title: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: const Text(
                        'Sign out of this device. Your emergency QR will remain active.',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: _confirmLogout,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _isDeletingAccount
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_forever_rounded,
                              color: AppColors.error, size: 22),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      subtitle: const Text(
                        'DPDPA Right to Erasure: Permanently delete all profile and medical data',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: _isDeletingAccount ? null : _confirmDeleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // App Version & Build Footer
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Golden Hour — Every Second Counts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'App Version 1.0.0 (Build 1) • Production Release',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DPDPA 2023 Compliant • Secure 256-bit AES Vault',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(String phone, String? fullName) {
    return Container(
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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              (fullName != null && fullName.isNotEmpty)
                  ? fullName.substring(0, 1).toUpperCase()
                  : 'P',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName ?? 'Patient Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'DPDPA Verified Account',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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



  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.8,
      ),
    );
  }
}
