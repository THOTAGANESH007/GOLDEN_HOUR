import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/domain/auth_provider.dart';
import '../data/profile_models.dart';
import '../domain/profile_provider.dart';

class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final completion = profileState.completion;
    final contacts = profileState.contacts;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Golden Hour'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Emergency Alerts',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Privacy Settings',
            onPressed: () => context.push('/profile/privacy'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text(
                      'Are you sure you want to log out of Golden Hour?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(profileNotifierProvider.notifier).loadProfileData(),
          child: profileState.isLoading && profile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Incomplete Wizard Alert Banner
                      if (profile != null && !profile.wizardCompleted) ...[
                        _buildWizardAlert(context),
                        const SizedBox(height: 16),
                      ],

                      // Patient Summary Card
                      _buildPatientSummaryCard(
                          context, ref, profile, authState.phone),
                      const SizedBox(height: 16),

                      // QR Code Quick Access Card
                      Card(
                        color: AppColors.primary,
                        child: InkWell(
                          onTap: () => context.push('/qr'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.qr_code_2_rounded,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'View Emergency QR Code',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Instant offline scan for first responders',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    color: Colors.white70, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Completion Score Card
                      if (completion != null) ...[
                        _buildCompletionCard(context, completion),
                        const SizedBox(height: 16),
                      ],

                      // Critical Emergency Info (Allergies, Blood, Conditions)
                      _buildEmergencyInfoCard(context, profile),
                      const SizedBox(height: 16),

                      // Emergency Contacts Section
                      _buildContactsSection(context, contacts),
                      const SizedBox(height: 16),

                      // Medical Documents Vault Card
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.infoLight,
                            child: Icon(Icons.folder_shared_rounded,
                                color: AppColors.info),
                          ),
                          title: const Text('Medical Records & Vault',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text(
                              'Prescriptions, Lab Reports, Insurance Cards',
                              style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => context.push('/documents'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Hub Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/profile/edit'),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Edit Profile'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  context.push('/profile/wizard'),
                              icon: const Icon(Icons.auto_fix_high_rounded),
                              label: const Text('Profile Wizard'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWizardAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.priority_high_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Incomplete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Complete the 5-step emergency wizard so first responders have your lifesaving data.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/profile/wizard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSummaryCard(
    BuildContext context,
    WidgetRef ref,
    PatientProfile? profile,
    String? phone,
  ) {
    final theme = Theme.of(context);
    final isQrActive = profile?.qrIsActive ?? true;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (profile?.fullName != null &&
                            profile!.fullName!.isNotEmpty)
                        ? profile.fullName![0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Patient Profile',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone ?? 'Registered Patient',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (profile?.bloodGroup != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                profile!.bloodGroup!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (profile?.gender != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                profile!.gender!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isQrActive
                          ? Icons.qr_code_2_rounded
                          : Icons.qr_code_scanner_rounded,
                      color: isQrActive ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isQrActive ? 'QR Medical Tag Active' : 'QR Tag Deactivated',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isQrActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: isQrActive,
                  activeThumbColor: AppColors.success,
                  onChanged: (val) {
                    ref
                        .read(profileNotifierProvider.notifier)
                        .toggleQrActive(val);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(
      BuildContext context, ProfileCompletion completion) {
    final theme = Theme.of(context);
    final score = completion.score;
    Color scoreColor = AppColors.error;
    if (score >= 80) {
      scoreColor = AppColors.success;
    } else if (score >= 50) {
      scoreColor = AppColors.secondary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Readiness Score',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
            if (completion.missing.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Missing: ${completion.missing.map((e) => e.replaceAll('_', ' ')).join(', ')}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyInfoCard(BuildContext context, PatientProfile? profile) {
    final theme = Theme.of(context);
    final allergies = profile?.allergies ?? [];
    final conditions = profile?.chronicConditions ?? [];
    final medications = profile?.medications ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Critical Medical Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Allergies
            Text(
              'Allergies:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            if (allergies.isEmpty)
              const Text('None recorded', style: TextStyle(fontSize: 13))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: allergies.map((a) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      a,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 14),

            // Conditions
            Text(
              'Chronic Conditions:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            if (conditions.isEmpty)
              const Text('None recorded', style: TextStyle(fontSize: 13))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: conditions.map((c) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 14),

            // Medications
            Text(
              'Active Medications (${medications.length}):',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            if (medications.isEmpty)
              const Text('No regular medications',
                  style: TextStyle(fontSize: 13))
            else
              Column(
                children: medications
                    .take(3)
                    .map((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 6, color: AppColors.info),
                              const SizedBox(width: 8),
                              Text('${m.name} (${m.dosage})',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsSection(
      BuildContext context, List<EmergencyContact> contacts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Emergency Contacts (${contacts.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/profile/wizard'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add / Manage'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (contacts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No emergency contacts added yet. Add loved ones to receive instant GPS alerts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = contacts[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(c.relation,
                            style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  subtitle: Text(c.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone_rounded,
                        color: AppColors.success),
                    onPressed: () {
                      final uri = Uri.parse('tel:${c.phone}');
                      launchUrl(uri);
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
