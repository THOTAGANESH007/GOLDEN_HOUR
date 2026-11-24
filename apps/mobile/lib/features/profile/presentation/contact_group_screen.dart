import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/profile_models.dart';
import '../domain/profile_provider.dart';

class ContactGroupScreen extends ConsumerStatefulWidget {
  const ContactGroupScreen({super.key});

  @override
  ConsumerState<ContactGroupScreen> createState() => _ContactGroupScreenState();
}

class _ContactGroupScreenState extends ConsumerState<ContactGroupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).fetchContactGroups();
    });
  }

  void _showCreateEditGroupDialog({ContactGroup? group}) {
    final isEditing = group != null;
    final nameController = TextEditingController(text: group?.name ?? '');
    final descController = TextEditingController(text: group?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Safety Group' : 'New Safety Group',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name *',
                    hintText: 'e.g. Family, Workplace, Neighbors',
                    prefixIcon: Icon(Icons.group_work_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter a group name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Primary family contacts for emergencies',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(isEditing ? 'Save Changes' : 'Create Group'),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.of(ctx).pop();
                      final notifier = ref.read(profileNotifierProvider.notifier);
                      bool ok;
                      if (isEditing) {
                        ok = await notifier.updateContactGroup(
                          group.id,
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                        );
                      } else {
                        ok = await notifier.createContactGroup(
                          nameController.text.trim(),
                          description: descController.text.trim(),
                        );
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? (isEditing ? 'Group updated' : 'Group created')
                                : 'Failed to save group'),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManageMembersDialog(ContactGroup group) {
    final allContacts = ref.read(profileNotifierProvider).contacts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final groupMemberIds = group.contacts.map((c) => c.id).toSet();

          return Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage "${group.name}" Members',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select contacts that belong to this emergency safety group:',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: allContacts.isEmpty
                      ? const Center(
                          child: Text('No emergency contacts found. Add contacts first.'),
                        )
                      : ListView.separated(
                          itemCount: allContacts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final c = allContacts[idx];
                            final isMember = groupMemberIds.contains(c.id);

                            return CheckboxListTile(
                              title: Text(
                                c.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${c.relation} • ${c.phone}'),
                              value: isMember,
                              activeColor: AppColors.primary,
                              onChanged: (bool? val) async {
                                if (val == null || c.id == null) return;
                                final notifier =
                                    ref.read(profileNotifierProvider.notifier);
                                if (val) {
                                  await notifier.addContactToGroup(group.id, c.id!);
                                } else {
                                  await notifier.removeContactFromGroup(group.id, c.id!);
                                }
                                // Update local state for immediate feedback
                                final updatedGroups =
                                    ref.read(profileNotifierProvider).contactGroups;
                                final refreshed = updatedGroups.firstWhere(
                                  (g) => g.id == group.id,
                                  orElse: () => group,
                                );
                                setModalState(() {
                                  group = refreshed;
                                });
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBroadcastDialog({ContactGroup? targetGroup}) {
    final noteController = TextEditingController();
    final addressController = TextEditingController();
    bool isBroadcasting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final title = targetGroup != null
              ? 'Broadcast to "${targetGroup.name}"'
              : 'Broadcast to All Contacts';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(ctx).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sends an automated emergency safety notification via WhatsApp and Push Notification to members of this group.',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Note (Optional)',
                      hintText: 'e.g. Minor vehicle mishap, feeling dizzy',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Current Location / Landmark (Optional)',
                      hintText: 'e.g. Near Metro Station Gate 2, Jubilee Hills',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: isBroadcasting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(isBroadcasting
                          ? 'Broadcasting...'
                          : 'Send Emergency Broadcast'),
                      onPressed: isBroadcasting
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              setModalState(() => isBroadcasting = true);
                              final res = await ref
                                  .read(profileNotifierProvider.notifier)
                                  .broadcastEmergencyAlert(
                                    groupId: targetGroup?.id,
                                    message: noteController.text.trim().isEmpty
                                        ? null
                                        : noteController.text.trim(),
                                    address: addressController.text.trim().isEmpty
                                        ? null
                                        : addressController.text.trim(),
                                  );
                              setModalState(() => isBroadcasting = false);
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();

                              if (!mounted) return;
                              if (res != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Broadcast sent! (${res.whatsappSentCount} WhatsApp, ${res.fcmSentCount} Push)',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                final err = ref
                                    .read(profileNotifierProvider)
                                    .errorMessage;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(err ?? 'Broadcast failed'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteGroup(ContactGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text(
          'Are you sure you want to delete the "${group.name}" group? Contacts in this group will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ref
                  .read(profileNotifierProvider.notifier)
                  .deleteContactGroup(group.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Group deleted' : 'Failed to delete group'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groups = state.contactGroups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Contact Groups'),
        actions: [
          IconButton(
            tooltip: 'Add Group',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateEditGroupDialog(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(profileNotifierProvider.notifier).fetchContactGroups(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Broadcast All Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: AppColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Emergency Alert',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Broadcast an alert to all contacts in 1 tap',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showBroadcastDialog(),
                          child: const Text('Broadcast'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Organized Safety Groups (${groups.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New Group'),
                        onPressed: () => _showCreateEditGroupDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (groups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Contact Groups Created',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Group contacts into "Family", "Workplace", or "Neighbors" for targeted emergency broadcasts.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create First Group'),
                            onPressed: () => _showCreateEditGroupDialog(),
                          ),
                        ],
                      ),
                    )
                  else
                    ...groups.map((group) {
                      final memberCount = group.contacts.length;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.folder_shared_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      group.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showCreateEditGroupDialog(group: group);
                                    } else if (val == 'members') {
                                      _showManageMembersDialog(group);
                                    } else if (val == 'delete') {
                                      _confirmDeleteGroup(group);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'members',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_add_outlined,
                                              size: 18),
                                          SizedBox(width: 8),
                                          Text('Manage Members'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit Group'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 18, color: AppColors.error),
                                          SizedBox(width: 8),
                                          Text('Delete Group',
                                              style: TextStyle(
                                                  color: AppColors.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (group.description != null &&
                                group.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                group.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Members chips
                            if (group.contacts.isEmpty)
                              Text(
                                'No members assigned yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: group.contacts.map((c) {
                                  return Chip(
                                    avatar: CircleAvatar(
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        c.name.isNotEmpty
                                            ? c.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    label: Text(
                                      '${c.name} (${c.relation})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            // Action buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.people_outline,
                                      size: 16),
                                  label: Text('Members ($memberCount)'),
                                  onPressed: () =>
                                      _showManageMembersDialog(group),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                        color: AppColors.error),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  icon: const Icon(Icons.campaign_outlined,
                                      size: 16),
                                  label: const Text('Broadcast'),
                                  onPressed: () =>
                                      _showBroadcastDialog(targetGroup: group),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
