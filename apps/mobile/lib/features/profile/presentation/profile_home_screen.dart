import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/domain/auth_provider.dart';
import '../data/profile_models.dart';
import '../domain/profile_provider.dart';
import '../../notifications/services/fcm_service.dart';

class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final completion = profileState.completion;
    final contacts = profileState.contacts;

    // Initialize FCM and synchronize token with backend on home entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmServiceProvider).initialize(
        onForegroundMessage: (message) {
          final title = message.notification?.title ?? 'Emergency Alert';
          final body = message.notification?.body ?? 'Your QR was scanned.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(body, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () => context.push('/notifications'),
              ),
            ),
          );
        },
        onNotificationClick: (message) {
          context.push('/notifications');
        },
      );
      ref.read(fcmServiceProvider).syncTokenWithBackend();
    });

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
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
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
                      _buildContactsSection(context, ref, contacts),
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
                      const SizedBox(height: 12),

                      // Emergency Scan History & Audit Card
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.history_toggle_off_rounded,
                                color: AppColors.primary),
                          ),
                          title: const Text('Emergency QR Scan History',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text(
                              'Incident logs, GPS coordinates, false alarms',
                              style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => context.push('/scan-history'),
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
                          if (profile?.age != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.infoLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.info.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${profile!.age} yrs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: score / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: animValue,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.outline.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
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
      BuildContext context, WidgetRef ref, List<EmergencyContact> contacts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Emergency Contacts (${contacts.length}/5)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: contacts.length >= 5
                  ? null
                  : () => _showAddContactBottomSheet(context, ref),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Add Contact'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (contacts.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contact_emergency_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Emergency Contacts Added',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'When responders scan your QR, these contacts receive instant GPS location and hospital alerts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddContactBottomSheet(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Emergency Contact'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = contacts[index];
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c.relation,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              c.phone,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (c.whatsappEnabled)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.chat_bubble_outline,
                                            size: 13,
                                            color: AppColors.success),
                                        SizedBox(width: 3),
                                        Text('WhatsApp',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.success)),
                                      ],
                                    ),
                                  ),
                                if (c.notifyOnScan)
                                  const Row(
                                    children: [
                                      Icon(Icons.notifications_active_outlined,
                                          size: 13, color: AppColors.primary),
                                      SizedBox(width: 3),
                                      Text('Scan Alert',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_rounded,
                                color: AppColors.success),
                            tooltip: 'Call Contact',
                            onPressed: () {
                              final uri = Uri.parse('tel:${c.phone}');
                              launchUrl(uri);
                            },
                          ),
                          if (c.id != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.error),
                              tooltip: 'Delete Contact',
                              onPressed: () =>
                                  _confirmDeleteContact(context, ref, c),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _confirmDeleteContact(
      BuildContext context, WidgetRef ref, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
            'Are you sure you want to remove ${contact.name} (${contact.phone}) from your emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(profileNotifierProvider.notifier)
                  .deleteEmergencyContact(contact.id!);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${contact.name}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  final err = ref.read(profileNotifierProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err ?? 'Failed to delete contact'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddContactBottomSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = 'Spouse';
    bool whatsappEnabled = true;
    bool notifyOnScan = true;
    bool isSubmitting = false;

    const relationOptions = [
      'Spouse',
      'Parent',
      'Child',
      'Sibling',
      'Friend',
      'Doctor',
      'Guardian',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Emergency Contact',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This contact will receive instant SMS & WhatsApp alerts with your live location when your QR code is scanned.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Name
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Contact Full Name',
                        hintText: 'e.g. Ramesh Thota',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Relationship & Phone
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedRelation,
                            decoration: const InputDecoration(
                              labelText: 'Relationship',
                              prefixIcon: Icon(Icons.people_outline),
                            ),
                            items: relationOptions.map((r) {
                              return DropdownMenuItem(value: r, child: Text(r));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedRelation = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '9876543210',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Toggles
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('WhatsApp Notifications',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Send location & hospital alerts via WhatsApp',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: whatsappEnabled,
                      onChanged: (val) =>
                          setModalState(() => whatsappEnabled = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Instant Scan Alerts',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Trigger SMS and WhatsApp alert when responder scans QR',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: notifyOnScan,
                      onChanged: (val) =>
                          setModalState(() => notifyOnScan = val),
                    ),
                    const SizedBox(height: 18),

                    // Save Button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final rawPhone = phoneController.text.trim();

                              if (name.isEmpty || rawPhone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter name and phone number'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              // Sanitize phone input
                              var digits = rawPhone.replaceAll(RegExp(r'\D'), '');
                              if (digits.startsWith('00')) {
                                digits = digits.substring(2);
                              } else if (digits.startsWith('0') &&
                                  digits.length == 11) {
                                digits = digits.substring(1);
                              }

                              String formattedPhone;
                              if (digits.length == 10) {
                                formattedPhone = '+91$digits';
                              } else if (digits.length > 10) {
                                formattedPhone = '+$digits';
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter a valid 10-digit mobile number'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final newContact = EmergencyContact(
                                name: name,
                                relation: selectedRelation,
                                phone: formattedPhone,
                                whatsappEnabled: whatsappEnabled,
                                notifyOnScan: notifyOnScan,
                              );

                              final success = await ref
                                  .read(profileNotifierProvider.notifier)
                                  .addEmergencyContact(newContact);

                              if (!context.mounted) return;

                              if (success) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added $name to emergency contacts!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                setModalState(() => isSubmitting = false);
                                final err = ref
                                    .read(profileNotifierProvider)
                                    .errorMessage;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        err ?? 'Failed to add emergency contact'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Emergency Contact',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
